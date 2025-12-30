import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mentor_assistant/core/errors/failures.dart';
import 'package:mentor_assistant/core/services/connectivity_helper.dart';
import 'package:mentor_assistant/core/utils/google_sheet_url_parser.dart';
import 'package:mentor_assistant/features/follow_up/data/datasources/sheets_remote_data_source.dart';
import 'package:mentor_assistant/features/report/domain/repositories/report_repository.dart';
import 'package:mentor_assistant/features/settings/domain/entities/group_config_entity.dart';

@LazySingleton(as: ReportRepository)
class ReportRepositoryImpl implements ReportRepository {
  final SheetsRemoteDataSource _remoteDataSource;

  ReportRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, Map<String, int>>> calculateGroupStats({
    required GroupConfigEntity group,
    required String assignmentSheetUrl,
    required String followUpSheetUrl,
    required String assignmentColumn,
    required String followUpColumn,
    required String assignmentEmailAnchorColumn,
    required String followUpEmailAnchorColumn,
  }) async {
    // 1. Check Connectivity
    final isConnected = await ConnectivityHelper.checkInternetConnection();
    if (!isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }
    try {
      // 2. Parse URLs using generic 'parse' method
      final assignmentInfo = GoogleSheetUrlParser.parse(assignmentSheetUrl);
      final followUpInfo = GoogleSheetUrlParser.parse(followUpSheetUrl);

      if (assignmentInfo == null || followUpInfo == null) {
        return const Left(SheetFailure('Invalid Sheet URLs'));
      }

      // Fetch Assignment Data
      // We need to convert Column Letter to Index (0-based)
      final assignColIndex = _columnIndex(assignmentColumn);
      final followUpColIndex = _columnIndex(followUpColumn);
      final assignAnchorColIndex = _columnIndex(assignmentEmailAnchorColumn);
      final followUpAnchorColIndex = _columnIndex(followUpEmailAnchorColumn);

      final results = await Future.wait([
        // 0: Assignment Data
        _remoteDataSource.getColumnData(
          spreadsheetId: assignmentInfo.spreadsheetId,
          sheetId: assignmentInfo.gid,
          columnIndex: assignColIndex,
          startRow: group.assignmentStartRow,
          endRow: group.assignmentEndRow,
        ),
        // 1: Assignment Anchor (Email)
        _remoteDataSource.getColumnData(
          spreadsheetId: assignmentInfo.spreadsheetId,
          sheetId: assignmentInfo.gid,
          columnIndex: assignAnchorColIndex,
          startRow: group.assignmentStartRow,
          endRow: group.assignmentEndRow,
        ),
        // 2: Follow-up Data
        _remoteDataSource.getColumnData(
          spreadsheetId: followUpInfo.spreadsheetId,
          sheetId: followUpInfo.gid,
          columnIndex: followUpColIndex,
          startRow: group.followUpStartRow,
          endRow: group.followUpEndRow,
        ),
        // 3: Follow-up Anchor (Email)
        _remoteDataSource.getColumnData(
          spreadsheetId: followUpInfo.spreadsheetId,
          sheetId: followUpInfo.gid,
          columnIndex: followUpAnchorColIndex,
          startRow: group.followUpStartRow,
          endRow: group.followUpEndRow,
        ),
      ]);

      // Unpack results safely
      final assignmentData = results[0];
      final assignmentAnchorData = results[1];
      final followUpData = results[2];
      final followUpAnchorData = results[3];

      // 4. Calculate Stats (Decoupled Loops)
      int submitted = 0;
      int unsubmitted = 0;
      int followUp = 0;

      // Loop 1: Calculate Assignment Stats with Anchor Check
      for (int i = 0; i < assignmentData.length; i++) {
        if (i >= assignmentAnchorData.length) break;

        final String anchorVal = assignmentAnchorData[i].trim();
        if (anchorVal.isEmpty) {
          continue;
        }

        final String val = assignmentData[i];
        if (val.trim().isNotEmpty) {
          submitted++;
        } else {
          unsubmitted++;
        }
      }

      // Loop 2: Calculate Follow-up Stats with Anchor Check
      for (int i = 0; i < followUpData.length; i++) {
        if (i >= followUpAnchorData.length) break;

        final String anchorVal = followUpAnchorData[i].trim();
        if (anchorVal.isEmpty) {
          continue;
        }

        final String val = followUpData[i];
        final String followUpVal = val.trim().toLowerCase();
        if (followUpVal.isNotEmpty && !followUpVal.contains('done')) {
          followUp++;
        }
      }

      return Right({
        'submitted': submitted,
        'unsubmitted': unsubmitted,
        'followUp': followUp,
      });
    } catch (e) {
      return Left(SheetFailure(e.toString()));
    }
  }

  int _columnIndex(String column) {
    column = column.trim().toUpperCase();
    int sum = 0;
    for (int i = 0; i < column.length; i++) {
      sum *= 26;
      sum += (column.codeUnitAt(i) - 'A'.codeUnitAt(0) + 1);
    }
    return sum - 1;
  }
}

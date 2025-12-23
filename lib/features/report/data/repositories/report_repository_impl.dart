import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mentor_assistant/core/errors/failures.dart';
import 'package:mentor_assistant/core/services/connectivity_helper.dart';
import 'package:mentor_assistant/core/utils/google_sheet_url_parser.dart';
import 'package:mentor_assistant/features/follow_up/data/datasources/sheets_remote_data_source.dart';
import 'package:mentor_assistant/features/report/domain/repositories/report_repository.dart';
import 'package:mentor_assistant/features/settings/data/models/group_config_model.dart';

@LazySingleton(as: ReportRepository)
class ReportRepositoryImpl implements ReportRepository {
  final SheetsRemoteDataSource _remoteDataSource;

  ReportRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, Map<String, int>>> calculateGroupStats({
    required GroupConfigModel group,
    required String assignmentSheetUrl,
    required String followUpSheetUrl,
    required String assignmentColumn,
    required String followUpColumn,
  }) async {
    // 1. Check Connectivity
    final isConnected = await ConnectivityHelper.checkInternetConnection();
    if (!isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }
    log('followUpColumn: $followUpColumn');
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

      log('assignmentStartRow: ${group.assignmentStartRow}');
      log('assignmentEndRow: ${group.assignmentEndRow}');
      log('followUpStartRow: ${group.followUpStartRow}');
      log('followUpEndRow: ${group.followUpEndRow}');
      final assignmentData = await _remoteDataSource.getColumnData(
        spreadsheetId: assignmentInfo.spreadsheetId,
        sheetId: assignmentInfo.gid, // Passing GID instead of Name
        columnIndex: assignColIndex,
        startRow: group.assignmentStartRow,
        endRow: group.assignmentEndRow,
      );

      final followUpData = await _remoteDataSource.getColumnData(
        spreadsheetId: followUpInfo.spreadsheetId,
        sheetId: followUpInfo.gid,
        columnIndex: followUpColIndex,
        startRow: group.followUpStartRow,
        endRow: group.followUpEndRow,
      );

      // 4. Calculate Stats (Decoupled Loops)
      int submitted = 0;
      int unsubmitted = 0;
      int followUp = 0;

      // Loop 1: Calculate Assignment Stats
      for (var val in assignmentData) {
        if (val.trim().isNotEmpty) {
          submitted++;
        } else {
          unsubmitted++;
        }
      }

      // Loop 2: Calculate Follow-up Stats
      for (var val in followUpData) {
        final followUpVal = val.trim().toLowerCase();
        // Check for specific keywords
        if (followUpVal.contains('email sent') ||
            followUpVal.contains('sent') ||
            followUpVal.contains('emailsent')) {
          // Added 'emailsent' based on your log just in case
          followUp++;
        }
      }

      // Log final results for confirmation
      log(
        'Final Stats -> Submitted: $submitted, Unsubmitted: $unsubmitted, FollowUp: $followUp',
      );

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

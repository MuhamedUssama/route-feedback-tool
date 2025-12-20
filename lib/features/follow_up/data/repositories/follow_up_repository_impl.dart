import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/sheet_column_entity.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/follow_up_config_entity.dart';
import '../../domain/repositories/follow_up_repository.dart';
import '../datasources/follow_up_local_data_source.dart';
import '../datasources/gmail_remote_data_source.dart';
import '../datasources/sheets_remote_data_source.dart';
import '../models/follow_up_config_model.dart';

@LazySingleton(as: FollowUpRepository)
class FollowUpRepositoryImpl implements FollowUpRepository {
  final SheetsRemoteDataSource _transportSheets;
  final GmailRemoteDataSource _transportGmail;
  final FollowUpLocalDataSource _localDataSource;

  FollowUpRepositoryImpl(
    this._transportSheets,
    this._transportGmail,
    this._localDataSource,
  );

  @override
  Future<Either<Failure, List<SheetColumnEntity>>> getSheetHeaders(
    String spreadsheetId,
    int sheetIndex,
    int headerRowIndex,
  ) async {
    try {
      final result = await _transportSheets.getSheetHeaders(
        spreadsheetId,
        sheetIndex,
        headerRowIndex,
      );
      return Right(result);
    } on SheetException catch (e) {
      return Left(Failure.sheet(e.message));
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudentEntity>>> checkMissingAssignments({
    required String masterSheetId,
    required int masterSheetIndex,
    required int masterHeaderRowIndex,
    required int localHeaderRowIndex,
    required int gradeColumnIndex,
    required String currentSheetId,
  }) async {
    try {
      final result = await _transportSheets.checkMissingAssignments(
        masterSheetId: masterSheetId,
        masterSheetIndex: masterSheetIndex,
        masterHeaderRowIndex: masterHeaderRowIndex,
        localHeaderRowIndex: localHeaderRowIndex,
        gradeColumnIndex: gradeColumnIndex,
        currentSheetId: currentSheetId,
      );
      return Right(result);
    } on SheetException catch (e) {
      return Left(Failure.sheet(e.message));
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendFollowUpEmail({
    required StudentEntity student,
    required String assignmentName,
  }) async {
    try {
      await _transportGmail.sendFollowUpEmail(
        student: student,
        assignmentName: assignmentName,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateStudentStatus({
    required String spreadsheetId,
    required int rowIndex,
    required int statusColumnIndex,
    required FollowUpAction action,
  }) async {
    try {
      await _transportSheets.updateStudentStatus(
        spreadsheetId: spreadsheetId,
        rowIndex: rowIndex,
        statusColumnIndex: statusColumnIndex,
        action: action,
      );
      return const Right(null);
    } on SheetException catch (e) {
      return Left(Failure.sheet(e.message));
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FollowUpConfigEntity?>> getFollowUpConfig() async {
    try {
      final config = await _localDataSource.getFollowUpConfig();
      return Right(config);
    } on CacheException catch (e) {
      return Left(Failure.cache(e.message));
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveFollowUpConfig(
    FollowUpConfigEntity config,
  ) async {
    try {
      final model = FollowUpConfigModel(
        assignmentsSheetId: config.assignmentsSheetId,
        followUpSheetId: config.followUpSheetId,
      );
      await _localDataSource.saveFollowUpConfig(model);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(Failure.cache(e.message));
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/sheet_column_entity.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/follow_up_config_entity.dart';
import '../../domain/repositories/follow_up_repository.dart';
import '../../domain/entities/assignment_analysis_result.dart';
import '../datasources/follow_up_local_data_source.dart';
import '../datasources/gmail_remote_data_source.dart';
import '../datasources/sheets_remote_data_source.dart';
import '../models/follow_up_config_model.dart';

@LazySingleton(as: FollowUpRepository)
class FollowUpRepositoryImpl implements FollowUpRepository {
  final SheetsRemoteDataSource _remoteDataSource;
  final GmailRemoteDataSource _transportGmail;
  final FollowUpLocalDataSource _localDataSource;

  FollowUpRepositoryImpl(
    this._remoteDataSource,
    this._transportGmail,
    this._localDataSource,
  );

  @override
  Future<Either<Failure, List<SheetColumnEntity>>> getSheetHeaders(
    String spreadsheetId,
    int? sheetId,
    int headerRowIndex, {
    bool detectMergedHeaders = false,
  }) async {
    try {
      final columns = await _remoteDataSource.getSheetHeaders(
        spreadsheetId,
        sheetId,
        headerRowIndex,
        detectMergedHeaders: detectMergedHeaders,
      );
      return Right(columns);
    } on GoogleAuthException catch (e) {
      return Left(AuthFailure(e.message, e.type));
    } on SheetException catch (e) {
      return Left(Failure.sheet(e.message));
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AssignmentAnalysisResult>> analyzeAssignmentStatus({
    required String masterSheetId,
    required int? masterSheetIdGid,
    required int masterHeaderRowIndex,
    required int localHeaderRowIndex,
    required int gradeColumnIndex,
    required String currentSheetId,
    required int? currentSheetIdGid,
  }) async {
    try {
      final result = await _remoteDataSource.analyzeAssignmentStatus(
        masterSheetId: masterSheetId,
        masterSheetIdGid: masterSheetIdGid,
        masterHeaderRowIndex: masterHeaderRowIndex,
        localHeaderRowIndex: localHeaderRowIndex,
        gradeColumnIndex: gradeColumnIndex,
        currentSheetId: currentSheetId,
        currentSheetIdGid: currentSheetIdGid,
      );
      return Right(result);
    } on GoogleAuthException catch (e) {
      return Left(AuthFailure(e.message, e.type));
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
    int? sheetId,
  }) async {
    try {
      await _remoteDataSource.updateStudentStatus(
        spreadsheetId: spreadsheetId,
        rowIndex: rowIndex,
        statusColumnIndex: statusColumnIndex,
        action: action,
        sheetId: sheetId,
      );
      return const Right(null);
    } on GoogleAuthException catch (e) {
      return Left(AuthFailure(e.message, e.type));
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
        assignmentsSheetUrl: config.assignmentsSheetUrl,
        followUpSheetUrl: config.followUpSheetUrl,
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

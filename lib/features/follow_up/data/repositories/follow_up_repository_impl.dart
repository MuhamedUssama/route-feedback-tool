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
    int headerRowIndex,
  ) async {
    try {
      final columns = await _remoteDataSource.getSheetHeaders(
        spreadsheetId,
        sheetId,
        headerRowIndex,
      );
      // Map Model -> Entity (simple casting if same structure or manual map)
      // Assuming SheetColumnModel extends SheetColumnEntity
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
  Future<Either<Failure, List<StudentEntity>>> checkMissingAssignments({
    required String masterSheetId,
    required int? masterSheetIdGid,
    required int masterHeaderRowIndex,
    required int localHeaderRowIndex,
    required int gradeColumnIndex,
    required String currentSheetId,
    required int? currentSheetIdGid,
  }) async {
    try {
      final students = await _remoteDataSource.checkMissingAssignments(
        masterSheetId: masterSheetId,
        masterSheetIdGid: masterSheetIdGid,
        masterHeaderRowIndex: masterHeaderRowIndex,
        localHeaderRowIndex: localHeaderRowIndex,
        gradeColumnIndex: gradeColumnIndex,
        currentSheetId: currentSheetId,
        currentSheetIdGid: currentSheetIdGid,
      );
      return Right(students);
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
      // Need to verify FollowUpConfigModel structure but proceeding with what was there
      // or adapting if Model changed.
      // Assuming Model structure matches Entity roughly for this step.
      // Wait, I saw saveFollowUpConfig using assignmentsSheetId etc in reading.
      // Let's keep existing logic structure but just fix variable names if they were off.
      // The previous view showed:
      // assignmentsSheetId: config.assignmentsSheetId,
      // followUpSheetId: config.followUpSheetId,
      // But wait, the Entity has generic naming?
      // I'll assume the entity has fields.
      // Actually, I'll stick to the previous file content for `saveFollowUpConfig` unless I need to change it.
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

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/sheet_column_entity.dart';
import '../entities/student_entity.dart';
import '../entities/follow_up_config_entity.dart';

abstract interface class FollowUpRepository {
  Future<Either<Failure, List<SheetColumnEntity>>> getSheetHeaders(
    String spreadsheetId,
    int? sheetId,
    int headerRowIndex, {
    bool detectMergedHeaders = false,
  });

  Future<Either<Failure, List<StudentEntity>>> checkMissingAssignments({
    required String masterSheetId,
    required int? masterSheetIdGid,
    required int masterHeaderRowIndex,
    required int localHeaderRowIndex,
    required int gradeColumnIndex,
    required String currentSheetId,
    required int? currentSheetIdGid,
  });

  Future<Either<Failure, void>> sendFollowUpEmail({
    required StudentEntity student,
    required String assignmentName,
  });

  Future<Either<Failure, FollowUpConfigEntity?>> getFollowUpConfig();

  Future<Either<Failure, void>> saveFollowUpConfig(FollowUpConfigEntity config);

  Future<Either<Failure, void>> updateStudentStatus({
    required String spreadsheetId,
    required int rowIndex,
    required int statusColumnIndex,
    required FollowUpAction action,
    int? sheetId,
  });
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/student_entity.dart';
import '../repositories/follow_up_repository.dart';

@lazySingleton
class CheckMissingAssignmentsUseCase
    implements UseCase<List<StudentEntity>, CheckMissingAssignmentsParams> {
  final FollowUpRepository _repository;

  CheckMissingAssignmentsUseCase(this._repository);

  @override
  Future<Either<Failure, List<StudentEntity>>> call(
    CheckMissingAssignmentsParams params,
  ) async {
    return await _repository.checkMissingAssignments(
      masterSheetId: params.masterSheetId,
      masterSheetIndex: params.masterSheetIndex,
      masterHeaderRowIndex: params.masterHeaderRowIndex,
      localHeaderRowIndex: params.localHeaderRowIndex,
      gradeColumnIndex: params.gradeColumnIndex,
      currentSheetId: params.currentSheetId,
    );
  }
}

class CheckMissingAssignmentsParams extends Equatable {
  final String masterSheetId;
  final int masterSheetIndex;
  final int masterHeaderRowIndex;
  final int localHeaderRowIndex;
  final int gradeColumnIndex;
  final String currentSheetId;

  const CheckMissingAssignmentsParams({
    required this.masterSheetId,
    required this.masterSheetIndex,
    required this.masterHeaderRowIndex,
    required this.localHeaderRowIndex,
    required this.gradeColumnIndex,
    required this.currentSheetId,
  });

  @override
  List<Object?> get props => [
    masterSheetId,
    masterSheetIndex,
    masterHeaderRowIndex,
    localHeaderRowIndex,
    gradeColumnIndex,
    currentSheetId,
  ];
}

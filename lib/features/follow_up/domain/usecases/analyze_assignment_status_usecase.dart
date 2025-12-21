import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';

import '../entities/assignment_analysis_result.dart';
import '../repositories/follow_up_repository.dart';

@lazySingleton
class AnalyzeAssignmentStatusUseCase
    implements
        UseCase<AssignmentAnalysisResult, AnalyzeAssignmentStatusParams> {
  final FollowUpRepository _repository;

  AnalyzeAssignmentStatusUseCase(this._repository);

  @override
  Future<Either<Failure, AssignmentAnalysisResult>> call(
    AnalyzeAssignmentStatusParams params,
  ) async {
    return await _repository.analyzeAssignmentStatus(
      masterSheetId: params.masterSheetId,
      masterSheetIdGid: params.masterSheetIdGid,
      masterHeaderRowIndex: params.masterHeaderRowIndex,
      localHeaderRowIndex: params.localHeaderRowIndex,
      gradeColumnIndex: params.gradeColumnIndex,
      currentSheetId: params.currentSheetId,
      currentSheetIdGid: params.currentSheetIdGid,
    );
  }
}

class AnalyzeAssignmentStatusParams extends Equatable {
  final String masterSheetId;
  final int? masterSheetIdGid;
  final int masterHeaderRowIndex;
  final int localHeaderRowIndex;
  final int gradeColumnIndex;
  final String currentSheetId;
  final int? currentSheetIdGid;

  const AnalyzeAssignmentStatusParams({
    required this.masterSheetId,
    required this.masterSheetIdGid,
    required this.masterHeaderRowIndex,
    required this.localHeaderRowIndex,
    required this.gradeColumnIndex,
    required this.currentSheetId,
    required this.currentSheetIdGid,
  });

  @override
  List<Object?> get props => [
    masterSheetId,
    masterSheetIdGid,
    masterHeaderRowIndex,
    localHeaderRowIndex,
    gradeColumnIndex,
    currentSheetId,
    currentSheetIdGid,
  ];
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/follow_up_config_entity.dart';
import '../repositories/follow_up_repository.dart';

@lazySingleton
class UpdateStudentStatusUseCase
    implements UseCase<void, UpdateStudentStatusParams> {
  final FollowUpRepository _repository;

  UpdateStudentStatusUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(UpdateStudentStatusParams params) async {
    return await _repository.updateStudentStatus(
      spreadsheetId: params.spreadsheetId,
      rowIndex: params.rowIndex,
      statusColumnIndex: params.statusColumnIndex,
      action: params.action,
      sheetId: params.sheetId,
    );
  }
}

class UpdateStudentStatusParams extends Equatable {
  final String spreadsheetId;
  final int rowIndex;
  final int statusColumnIndex;
  final FollowUpAction action;
  final int? sheetId;

  const UpdateStudentStatusParams({
    required this.spreadsheetId,
    required this.rowIndex,
    required this.statusColumnIndex,
    required this.action,
    this.sheetId,
  });

  @override
  List<Object?> get props => [
    spreadsheetId,
    rowIndex,
    statusColumnIndex,
    action,
    sheetId,
  ];
}

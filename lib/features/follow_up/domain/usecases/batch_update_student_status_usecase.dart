import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/student_status_update_model.dart';
import '../repositories/follow_up_repository.dart';

@lazySingleton
class BatchUpdateStudentStatusUseCase
    implements UseCase<void, BatchUpdateStudentStatusParams> {
  final FollowUpRepository _repository;

  BatchUpdateStudentStatusUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(
    BatchUpdateStudentStatusParams params,
  ) async {
    return await _repository.batchUpdateStudentStatus(
      spreadsheetId: params.spreadsheetId,
      updates: params.updates,
    );
  }
}

class BatchUpdateStudentStatusParams extends Equatable {
  final String spreadsheetId;
  final List<StudentStatusUpdateModel> updates;

  const BatchUpdateStudentStatusParams({
    required this.spreadsheetId,
    required this.updates,
  });

  @override
  List<Object?> get props => [spreadsheetId, updates];
}

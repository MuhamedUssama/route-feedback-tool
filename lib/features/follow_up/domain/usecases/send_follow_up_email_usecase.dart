import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/student_entity.dart';
import '../repositories/follow_up_repository.dart';

@lazySingleton
class SendFollowUpEmailUseCase
    implements UseCase<void, SendFollowUpEmailParams> {
  final FollowUpRepository _repository;

  SendFollowUpEmailUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(SendFollowUpEmailParams params) async {
    return await _repository.sendFollowUpEmail(
      student: params.student,
      assignmentName: params.assignmentName,
    );
  }
}

class SendFollowUpEmailParams extends Equatable {
  final StudentEntity student;
  final String assignmentName;

  const SendFollowUpEmailParams({
    required this.student,
    required this.assignmentName,
  });

  @override
  List<Object?> get props => [student, assignmentName];
}

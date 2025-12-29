import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/follow_up_repository.dart';

@lazySingleton
class GetCurrentUserEmailUseCase implements UseCase<String, NoParams> {
  final FollowUpRepository repository;

  GetCurrentUserEmailUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await repository.getCurrentUserEmail();
  }
}

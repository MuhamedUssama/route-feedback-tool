import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class CheckAutoLoginUseCase implements UseCase<UserEntity, NoParams> {
  final AuthRepository _repository;

  CheckAutoLoginUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    return await _repository.checkAutoLogin();
  }
}

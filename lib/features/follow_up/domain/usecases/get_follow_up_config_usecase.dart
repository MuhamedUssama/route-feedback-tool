import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/follow_up_config_entity.dart';
import '../repositories/follow_up_repository.dart';

@lazySingleton
class GetFollowUpConfigUseCase
    implements UseCase<FollowUpConfigEntity?, NoParams> {
  final FollowUpRepository _repository;

  GetFollowUpConfigUseCase(this._repository);

  @override
  Future<Either<Failure, FollowUpConfigEntity?>> call(NoParams params) async {
    return await _repository.getFollowUpConfig();
  }
}

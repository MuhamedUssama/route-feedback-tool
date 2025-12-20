import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/follow_up_config_entity.dart';
import '../repositories/follow_up_repository.dart';

@lazySingleton
class SaveFollowUpConfigUseCase
    implements UseCase<void, SaveFollowUpConfigParams> {
  final FollowUpRepository _repository;

  SaveFollowUpConfigUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(SaveFollowUpConfigParams params) async {
    return await _repository.saveFollowUpConfig(params.config);
  }
}

class SaveFollowUpConfigParams extends Equatable {
  final FollowUpConfigEntity config;

  const SaveFollowUpConfigParams(this.config);

  @override
  List<Object?> get props => [config];
}

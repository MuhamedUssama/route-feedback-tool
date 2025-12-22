import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mentor_assistant/core/errors/exceptions.dart';
import 'package:mentor_assistant/core/errors/failures.dart';
import 'package:mentor_assistant/features/settings/data/datasources/cycle_local_data_source.dart';
import 'package:mentor_assistant/features/settings/data/models/cycle_config_model.dart';
import 'package:mentor_assistant/features/settings/domain/entities/cycle_config_entity.dart';
import 'package:mentor_assistant/features/settings/domain/repositories/cycle_repository.dart';

@LazySingleton(as: CycleRepository)
class CycleRepositoryImpl implements CycleRepository {
  final CycleLocalDataSource _localDataSource;

  CycleRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, CycleConfigEntity?>> getConfig() async {
    try {
      final configModel = await _localDataSource.getConfig();
      return Right(configModel?.toEntity());
    } on CacheException {
      return Left(CacheFailure('Cache Failure'));
    }
  }

  @override
  Future<Either<Failure, void>> saveConfig(CycleConfigEntity config) async {
    try {
      final configModel = CycleConfigModel.fromEntity(config);
      await _localDataSource.saveConfig(configModel);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure('Cache Failure'));
    }
  }
}

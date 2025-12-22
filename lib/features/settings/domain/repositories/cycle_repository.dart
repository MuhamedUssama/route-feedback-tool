import 'package:dartz/dartz.dart';
import 'package:mentor_assistant/core/errors/failures.dart';
import 'package:mentor_assistant/features/settings/domain/entities/cycle_config_entity.dart';

abstract interface class CycleRepository {
  Future<Either<Failure, void>> saveConfig(CycleConfigEntity config);
  Future<Either<Failure, CycleConfigEntity?>> getConfig();
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mentor_assistant/core/errors/failures.dart';
import 'package:mentor_assistant/features/settings/domain/entities/cycle_config_entity.dart';
import 'package:mentor_assistant/features/settings/domain/repositories/cycle_repository.dart';
import 'package:mentor_assistant/features/settings/presentation/cubits/cycle_config/cycle_config_state.dart';

@injectable
class CycleConfigCubit extends Cubit<CycleConfigState> {
  final CycleRepository _repository;

  CycleConfigCubit(this._repository) : super(const CycleConfigState.initial());

  Future<void> loadConfig() async {
    emit(const CycleConfigState.loading());
    final result = await _repository.getConfig();
    result.fold(
      (failure) => emit(CycleConfigState.error(_mapFailureToMessage(failure))),
      (config) => emit(CycleConfigState.loaded(config)),
    );
  }

  Future<void> saveConfig(CycleConfigEntity config) async {
    emit(const CycleConfigState.loading());
    final result = await _repository.saveConfig(config);
    result.fold(
      (failure) => emit(CycleConfigState.error(_mapFailureToMessage(failure))),
      (_) {
        emit(const CycleConfigState.success());
        // Reload to show updated data
        emit(CycleConfigState.loaded(config));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is CacheFailure) {
      return 'Failed to save/load configuration locally.';
    }
    return 'Unexpected error occurred.';
  }
}

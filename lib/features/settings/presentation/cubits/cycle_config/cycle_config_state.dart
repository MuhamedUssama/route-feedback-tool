import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mentor_assistant/features/settings/domain/entities/cycle_config_entity.dart';

part 'cycle_config_state.freezed.dart';

@freezed
class CycleConfigState with _$CycleConfigState {
  const factory CycleConfigState.initial() = _Initial;
  const factory CycleConfigState.loading() = _Loading;
  const factory CycleConfigState.loaded(CycleConfigEntity? config) = _Loaded;
  const factory CycleConfigState.success() = _Success;
  const factory CycleConfigState.error(String message) = _Error;
}

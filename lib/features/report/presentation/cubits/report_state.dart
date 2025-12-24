import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mentor_assistant/features/auth/domain/entities/user_entity.dart';
import 'package:mentor_assistant/features/settings/data/models/cycle_config_model.dart';

part 'report_state.freezed.dart';

@freezed
class ReportState with _$ReportState {
  const factory ReportState.initial() = _Initial;
  const factory ReportState.loading() = _Loading;
  const factory ReportState.noConfig() = _NoConfig;
  const factory ReportState.ready({
    required CycleConfigModel config,
    required Map<String, Map<String, int>>
    groupStats, // key: groupName, val: {submitted: 0, etc}
    required UserEntity? user,
    @Default({}) Set<String> loadingGroupNames,
    String? errorMessage,
  }) = _Ready;
  const factory ReportState.error(String message) = _Error;
}

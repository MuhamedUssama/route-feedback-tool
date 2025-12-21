part of 'settings_cubit.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState.initial() = _Initial;
  const factory SettingsState.loading() = _Loading;

  const factory SettingsState.loaded({
    required UserEntity? user,
    required FollowUpConfigEntity? config,
    required bool isLoading,
    @Default(false) bool isTestingAssignment,
    @Default(false) bool isTestingFollowUp,
  }) = _Loaded;

  const factory SettingsState.success(String message) = _Success;
  const factory SettingsState.error(String message) = _Error;
}

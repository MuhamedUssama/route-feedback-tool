part of 'follow_up_config_cubit.dart';

@freezed
class FollowUpConfigState with _$FollowUpConfigState {
  const factory FollowUpConfigState.initial() = _Initial;
  const factory FollowUpConfigState.loading() = _Loading;
  const factory FollowUpConfigState.configLoaded(FollowUpConfigEntity config) =
      _ConfigLoaded;
  const factory FollowUpConfigState.configMissing() = _ConfigMissing;
  const factory FollowUpConfigState.error(String message) = _Error;
}

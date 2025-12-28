part of 'splash_cubit.dart';

@freezed
abstract class SplashState with _$SplashState {
  const factory SplashState.initial() = SplashInitial;
  const factory SplashState.loading({
    @Default('Initializing...') String message,
    @Default(0.0) double progress,
  }) = SplashLoading;
  const factory SplashState.authenticated(UserEntity user) = AuthAuthenticated;
  const factory SplashState.unauthenticated() = AuthUnauthenticated;
  const factory SplashState.error(String message) = SplashError;
}

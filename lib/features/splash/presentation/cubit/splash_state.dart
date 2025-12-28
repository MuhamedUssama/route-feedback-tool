part of 'splash_cubit.dart';

@freezed
class SplashState with _$SplashState {
  const factory SplashState.initial() = SplashInitial;
  const factory SplashState.loading() = SplashLoading;
  const factory SplashState.authenticated(UserEntity user) = AuthAuthenticated;
  const factory SplashState.unauthenticated() = AuthUnauthenticated;
  const factory SplashState.error(String message) = SplashError;
}

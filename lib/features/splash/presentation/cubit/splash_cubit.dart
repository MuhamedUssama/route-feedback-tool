import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';

part 'splash_state.dart';
part 'splash_cubit.freezed.dart';

@injectable
class SplashCubit extends Cubit<SplashState> {
  final AuthRepository _authRepository;

  SplashCubit(this._authRepository) : super(const SplashState.initial());

  Future<void> checkAutoLogin() async {
    emit(const SplashState.loading());

    // Artificial delay for splash animation (optional, user requested smooth transition)
    // But since the user implemented animation in SplashScreen, we might just fire this.
    // However, if we return too fast, the animation might be cut off?
    // The user handled animation timer in SplashScreen using Future.wait.
    // So here we strictly check login.

    final result = await _authRepository.checkAutoLogin();

    result.fold(
      (failure) => emit(const SplashState.unauthenticated()),
      (user) => emit(SplashState.authenticated(user)),
    );
  }
}

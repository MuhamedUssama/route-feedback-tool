import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/check_auto_login_usecase.dart';
import '../../domain/usecases/login_with_google_usecase.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;
  final CheckAutoLoginUseCase _checkAutoLoginUseCase;

  AuthCubit(this._loginWithGoogleUseCase, this._checkAutoLoginUseCase)
    : super(const AuthState.initial());

  Future<void> loginWithGoogle() async {
    emit(const AuthState.loading());
    final result = await _loginWithGoogleUseCase(const NoParams());
    result.fold(
      (failure) => emit(AuthState.failure(failure.message)),
      (user) => emit(AuthState.success(user)),
    );
  }

  Future<void> checkAuthStatus() async {
    // We don't emit loading here to avoid flashing login screen if we are just checking
    // But for BootstrapPage, we might want an initial state.
    // The BootstrapPage will likely start in 'initial' and call this.
    final result = await _checkAutoLoginUseCase(const NoParams());
    result.fold(
      (failure) => emit(AuthState.failure(failure.message)),
      (user) => emit(AuthState.success(user)),
    );
  }
}

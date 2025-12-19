import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/login_with_google_usecase.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;

  AuthCubit(this._loginWithGoogleUseCase) : super(const AuthState.initial());

  Future<void> loginWithGoogle() async {
    emit(const AuthState.loading());
    final result = await _loginWithGoogleUseCase(const NoParams());
    result.fold(
      (failure) => emit(AuthState.failure(failure.message)),
      (user) => emit(AuthState.success(user)),
    );
  }
}

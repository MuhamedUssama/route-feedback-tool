import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';

part 'splash_state.dart';
part 'splash_cubit.freezed.dart';

@injectable
class SplashCubit extends Cubit<SplashState> {
  final AuthRepository _authRepository;
  Timer? _timer;

  SplashCubit(this._authRepository) : super(const SplashState.initial());

  Future<void> initializeApp() async {
    emit(const SplashState.loading(progress: 0.0));

    _startProgressTimer();

    try {
      final results = await Future.wait([
        Future.delayed(const Duration(seconds: 3)),
        _checkAuthResult(),
      ]);
      final authResult = results[1] as Either<Failure, UserEntity>;

      if (!isClosed) {
        authResult.fold(
          (failure) => emit(const SplashState.unauthenticated()),
          (user) => emit(SplashState.authenticated(user)),
        );
      }
    } catch (e) {
      if (!isClosed) emit(SplashState.error(e.toString()));
    }
  }

  Future<Either<Failure, UserEntity>> _checkAuthResult() async {
    return await _authRepository.checkAutoLogin();
  }

  void _startProgressTimer() {
    double progress = 0.0;
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (progress >= 1.0) {
        timer.cancel();
      } else {
        progress += 0.02;
        if (!isClosed) {
          state.maybeMap(
            loading: (s) =>
                emit(s.copyWith(progress: progress > 1.0 ? 1.0 : progress)),
            orElse: () {},
          );
        }
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

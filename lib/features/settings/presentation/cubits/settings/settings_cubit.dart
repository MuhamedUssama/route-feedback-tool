import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:mentor_assistant/features/auth/domain/entities/user_entity.dart';
import 'package:mentor_assistant/features/auth/domain/repositories/auth_repository.dart';
import 'package:mentor_assistant/features/follow_up/domain/entities/follow_up_config_entity.dart';
import 'package:mentor_assistant/features/follow_up/domain/repositories/follow_up_repository.dart';
import 'package:mentor_assistant/features/settings/domain/usecases/test_sheet_connection_usecase.dart';

part 'settings_state.dart';
part 'settings_cubit.freezed.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final AuthRepository _authRepository;
  final FollowUpRepository _followUpRepository;
  final TestSheetConnectionUseCase _testConnectionUseCase;

  SettingsCubit(
    this._authRepository,
    this._followUpRepository,
    this._testConnectionUseCase,
  ) : super(const SettingsState.initial());

  Future<void> loadSettings() async {
    emit(const SettingsState.loading());

    final userResult = await _authRepository.getCachedUser();
    final configResult = await _followUpRepository.getFollowUpConfig();

    final user = userResult.fold((_) => null, (u) => u);
    final config = configResult.fold((_) => null, (c) => c);

    emit(SettingsState.loaded(user: user, config: config, isLoading: false));
  }

  Future<void> testAssignmentConnection(String url) async {
    final currentState = state;
    if (currentState is! _Loaded) return;

    emit(currentState.copyWith(isTestingAssignment: true));

    final result = await _testConnectionUseCase(
      TestSheetConnectionParams(url: url),
    );

    result.fold(
      (failure) => emit(SettingsState.error(failure.message)),
      (_) => emit(const SettingsState.success("Assignment Sheet Connected!")),
    );

    // Restore state
    emit(currentState.copyWith(isTestingAssignment: false));
  }

  Future<void> testFollowUpConnection(String url) async {
    final currentState = state;
    if (currentState is! _Loaded) return;

    emit(currentState.copyWith(isTestingFollowUp: true));

    final result = await _testConnectionUseCase(
      TestSheetConnectionParams(url: url),
    );

    result.fold(
      (failure) => emit(SettingsState.error(failure.message)),
      (_) => emit(const SettingsState.success("Follow Up Sheet Connected!")),
    );

    // Restore state
    emit(currentState.copyWith(isTestingFollowUp: false));
  }

  Future<void> saveConfig({
    required String assignmentUrl,
    required String followUpUrl,
  }) async {
    final currentState = state;
    if (currentState is! _Loaded) return;

    emit(currentState.copyWith(isLoading: true));

    // Validate URLs structure first? Repository handles saving.
    // For now we assume Strings are passed.

    // We update the config
    final newConfig = FollowUpConfigEntity(
      assignmentsSheetUrl: assignmentUrl,
      followUpSheetUrl: followUpUrl,
    );

    final result = await _followUpRepository.saveFollowUpConfig(newConfig);

    result.fold((failure) => emit(SettingsState.error(failure.message)), (_) {
      emit(const SettingsState.success("Settings Saved Successfully"));
      emit(currentState.copyWith(isLoading: false, config: newConfig));
    });
  }

  Future<void> logout() async {
    emit(const SettingsState.loading());
    await _authRepository.logout();
    // After logout, usually navigate away.
    // We can emit a specific state or just let the router listener handle it (if AuthState changes).
    // Here we just emit success/initial.
    emit(const SettingsState.initial());
  }
}

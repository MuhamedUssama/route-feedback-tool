import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/repositories/settings_repository.dart';

@singleton
class ThemeCubit extends Cubit<ThemeMode> {
  final SettingsRepository _settingsRepository;

  ThemeCubit(this._settingsRepository) : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final mode = await _settingsRepository.getThemeMode();
    emit(mode);
  }

  Future<void> updateTheme(ThemeMode mode) async {
    await _settingsRepository.saveThemeMode(mode);
    emit(mode);
  }
}

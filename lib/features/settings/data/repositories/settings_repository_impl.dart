import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:mentor_assistant/core/constants/app_constants.dart';
import 'package:mentor_assistant/core/services/shared_prefs_service.dart';
import '../../domain/repositories/settings_repository.dart';

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPrefsService _sharedPrefsService;

  SettingsRepositoryImpl(this._sharedPrefsService);

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    await _sharedPrefsService.saveData(
      key: AppConstants.kThemeModeKey,
      value: mode.index,
    );
  }

  @override
  Future<ThemeMode> getThemeMode() async {
    final index =
        _sharedPrefsService.getData(key: AppConstants.kThemeModeKey) as int?;
    if (index != null && index >= 0 && index < ThemeMode.values.length) {
      return ThemeMode.values[index];
    }
    return ThemeMode.system; // Default
  }
}

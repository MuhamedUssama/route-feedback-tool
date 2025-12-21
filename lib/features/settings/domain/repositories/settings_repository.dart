import 'package:flutter/material.dart';

abstract interface class SettingsRepository {
  Future<void> saveThemeMode(ThemeMode mode);
  Future<ThemeMode> getThemeMode();
}

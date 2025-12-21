import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:mentor_assistant/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class SharedPrefsService {
  final SharedPreferences _prefs;
  static const String _kSheetIdKey = 'master_sheet_id';

  SharedPrefsService(this._prefs);

  /// Generic method to save data
  /// Supports [String], [int], [bool], [double]
  Future<bool> saveData({required String key, required dynamic value}) async {
    if (value is String) {
      return await _prefs.setString(key, value);
    } else if (value is int) {
      return await _prefs.setInt(key, value);
    } else if (value is bool) {
      return await _prefs.setBool(key, value);
    } else if (value is double) {
      return await _prefs.setDouble(key, value);
    } else {
      throw Exception("Unsupported Value Type");
    }
  }

  /// Generic method to get data
  /// Returns [Object?] which can be casted to expected type
  Object? getData({required String key}) {
    return _prefs.get(key);
  }

  Future<void> saveSheetId(String id) async {
    await saveData(key: _kSheetIdKey, value: id);
  }

  String? getSheetId() {
    return getData(key: _kSheetIdKey) as String?;
  }

  Future<void> clearData() async {
    await _prefs.remove(_kSheetIdKey);
  }

  Future<UserModel?> getUser() async {
    final String? userJson = _prefs.getString('CACHED_USER');
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }
}

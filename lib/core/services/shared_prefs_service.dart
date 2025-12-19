import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class SharedPrefsService {
  final SharedPreferences _prefs;
  static const String _kSheetIdKey = 'master_sheet_id';

  SharedPrefsService(this._prefs);

  Future<void> saveSheetId(String id) async {
    await _prefs.setString(_kSheetIdKey, id);
  }

  String? getSheetId() {
    return _prefs.getString(_kSheetIdKey);
  }

  Future<void> clearData() async {
    await _prefs.remove(_kSheetIdKey);
  }
}

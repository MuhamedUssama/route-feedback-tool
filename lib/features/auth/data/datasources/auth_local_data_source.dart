import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract interface class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUserCache();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _prefs;
  const AuthLocalDataSourceImpl(this._prefs);

  static const String _kCachedUserKey = 'CACHED_USER';

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final jsonString = jsonEncode(user.toJson());
      await _prefs.setString(_kCachedUserKey, jsonString);
    } catch (e) {
      throw const CacheException('Failed to cache user');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = _prefs.getString(_kCachedUserKey);
      if (jsonString != null) {
        return UserModel.fromJson(jsonDecode(jsonString));
      }
      return null;
    } catch (e) {
      throw const CacheException('Failed to retrieve cached user');
    }
  }

  @override
  Future<void> clearUserCache() async {
    try {
      await _prefs.remove(_kCachedUserKey);
    } catch (e) {
      throw const CacheException('Failed to clear user cache');
    }
  }
}

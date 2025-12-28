import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:mentor_assistant/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import 'package:mentor_assistant/features/auth/data/models/credentials_model.dart';
import '../models/user_model.dart';

abstract interface class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> cacheCredentials(CredentialsModel credentials);
  Future<CredentialsModel?> getCachedCredentials();
  Future<void> clearUserCache();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _prefs;
  const AuthLocalDataSourceImpl(this._prefs);

  static const String _kCachedUserKey = AppConstants.kCachedUserKey;
  static const String _kCachedCredentialsKey =
      AppConstants.storageUserCredentialsKey;

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
  Future<void> cacheCredentials(CredentialsModel credentials) async {
    try {
      final jsonString = jsonEncode(credentials.toJson());
      await _prefs.setString(_kCachedCredentialsKey, jsonString);
    } catch (e) {
      throw const CacheException('Failed to cache credentials');
    }
  }

  @override
  Future<CredentialsModel?> getCachedCredentials() async {
    final jsonString = _prefs.getString(_kCachedCredentialsKey);
    if (jsonString != null) {
      try {
        return CredentialsModel.fromJson(
          jsonDecode(jsonString) as Map<String, dynamic>,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearUserCache() async {
    try {
      await _prefs.remove(_kCachedUserKey);
      await _prefs.remove(_kCachedCredentialsKey);
    } catch (e) {
      throw const CacheException('Failed to clear user cache');
    }
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/auth_error_type.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/google_auth_client.dart';
import '../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> loginWithGoogle();
  Future<void> signOut();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final GoogleAuthClient _googleAuthClient;

  AuthRemoteDataSourceImpl(this._googleAuthClient);

  @override
  Future<UserModel> loginWithGoogle() async {
    try {
      final client = await _googleAuthClient.getAuthenticatedClient();

      if (client == null) {
        throw const GoogleAuthException(
          'Sign-In cancelled or failed',
          AuthErrorType.cancelled,
        );
      }

      final response = await client.get(
        Uri.parse('https://www.googleapis.com/oauth2/v3/userinfo'),
      );

      if (response.statusCode == 200) {
        // Log Raw JSON for debugging
        if (kDebugMode) {
          print("🔍 Google User Info Raw JSON: ${response.body}");
        }

        final json = jsonDecode(response.body) as Map<String, dynamic>;

        return UserModel(
          id: json['sub'] as String,
          email: json['email'] as String,
          displayName:
              json['name'] as String? ??
              (json['email'] as String).split('@')[0],
          photoUrl: json['picture'] as String?,
          accessToken: '',
        );
      } else {
        throw ServerException(
          'Failed to fetch user info from Google',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is GoogleAuthException || e is ServerException) {
        rethrow;
      }
      throw GoogleAuthException(e.toString(), AuthErrorType.unknown);
    }
  }

  @override
  Future<void> signOut() async {
    await _googleAuthClient.signOut();
  }
}

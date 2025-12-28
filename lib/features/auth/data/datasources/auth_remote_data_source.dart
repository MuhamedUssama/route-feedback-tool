import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import '../../../../core/errors/auth_error_type.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/google_auth_client.dart';
import 'package:mentor_assistant/features/auth/data/models/credentials_model.dart';
import '../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<(UserModel, CredentialsModel?)> loginWithGoogle();
  Future<UserModel?> loginSilently(CredentialsModel? credentials);
  Future<void> signOut();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final GoogleAuthClient _googleAuthClient;
  const AuthRemoteDataSourceImpl(this._googleAuthClient);

  @override
  Future<(UserModel, CredentialsModel?)> loginWithGoogle() async {
    try {
      final (client, account) = await _googleAuthClient
          .getAuthenticatedClientAndAccount()
          .timeout(
            const Duration(seconds: 100),
            onTimeout: () {
              throw const GoogleAuthException(
                'Login timed out or was cancelled',
                AuthErrorType.cancelled,
              );
            },
          );

      if (client == null) {
        throw const GoogleAuthException(
          'Sign-In cancelled or failed',
          AuthErrorType.cancelled,
        );
      }

      // Capture credentials for Windows
      CredentialsModel? credentials;
      if (Platform.isWindows && client is AutoRefreshingAuthClient) {
        credentials = CredentialsModel.fromAccessCredentials(
          client.credentials,
        );
      }

      final user = await _getUserFromClientOrAccount(client, account);
      return (user, credentials);
    } catch (e) {
      if (e is GoogleAuthException || e is ServerException) {
        rethrow;
      }
      throw GoogleAuthException(e.toString(), AuthErrorType.unknown);
    }
  }

  @override
  Future<UserModel?> loginSilently(CredentialsModel? credentials) async {
    try {
      final (client, account) = await _googleAuthClient.signInSilently(
        credentials,
      );

      if (client != null) {
        return await _getUserFromClientOrAccount(client, account);
      }
      return null;
    } catch (e) {
      // If silent login fails, just return null (user needs to login explicitly)
      return null;
    }
  }

  Future<UserModel> _getUserFromClientOrAccount(
    http.Client client,
    GoogleSignInAccount? account,
  ) async {
    if (Platform.isWindows) {
      final response = await client.get(
        Uri.parse('https://www.googleapis.com/oauth2/v3/userinfo'),
      );

      if (response.statusCode == 200) {
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
    } else {
      if (account == null) {
        throw const GoogleAuthException(
          'No account found after sign in',
          AuthErrorType.unknown,
        );
      }

      return UserModel(
        id: account.id,
        email: account.email,
        displayName: account.displayName ?? account.email.split('@')[0],
        photoUrl: account.photoUrl,
        accessToken: '',
      );
    }
  }

  @override
  Future<void> signOut() async {
    await _googleAuthClient.signOut();
  }
}

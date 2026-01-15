import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthRemoteDataSourceImpl(this._googleAuthClient);

  @override
  Future<(UserModel, CredentialsModel?)> loginWithGoogle() async {
    try {
      final GoogleAuthProvider authProvider = GoogleAuthProvider();

      for (final scope in GoogleAuthClient.scopes) {
        authProvider.addScope(scope);
      }

      final UserCredential userCredential = await _firebaseAuth.signInWithPopup(
        authProvider,
      );

      final user = userCredential.user;
      if (user == null) {
        throw const ServerException('Firebase Sign-In failed: User is null');
      }

      await _googleAuthClient.getAuthenticatedClient();

      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        photoUrl: user.photoURL,
        accessToken: '',
      );

      return (userModel, null);
    } catch (e) {
      if (e is GoogleAuthException || e is ServerException) {
        rethrow;
      }
      if (e is FirebaseAuthException) {
        throw GoogleAuthException(
          e.message ?? 'Firebase Auth Error',
          AuthErrorType.unknown,
        );
      }
      throw GoogleAuthException(e.toString(), AuthErrorType.unknown);
    }
  }

  @override
  Future<UserModel?> loginSilently(CredentialsModel? credentials) async {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser != null) {
      _googleAuthClient.getAuthenticatedClient();

      try {
        await currentUser.reload();
      } catch (exception) {
        log(exception.toString());
      }

      return UserModel(
        id: currentUser.uid,
        email: currentUser.email ?? '',
        displayName: currentUser.displayName ?? '',
        photoUrl: currentUser.photoURL,
        accessToken: '',
      );
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_firebaseAuth.signOut(), _googleAuthClient.signOut()]);
  }
}

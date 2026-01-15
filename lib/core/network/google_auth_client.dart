import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@lazySingleton
class GoogleAuthClient {
  static const List<String> _scopes = [
    'email',
    'profile',
    'openid',
    SheetsApi.spreadsheetsScope,
    GmailApi.gmailSendScope,
    GmailApi.gmailReadonlyScope,
  ];

  // Access the singleton instance directly
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // We must cache the account locally because v7 doesn't expose a 'currentUser' getter
  GoogleSignInAccount? _cachedAccount;

  // Cache for the authenticated HTTP client
  http.Client? _cachedClient;

  // ================== Main Entry Point (for APIs) ==================
  /// Returns an authenticated HTTP client that injects the necessary headers.
  /// If the user is not signed in via GoogleSignIn, this returns null.
  Future<http.Client?> getAuthenticatedClient() async {
    // 1. If we have a cached client, return it.
    if (_cachedClient != null) {
      return _cachedClient;
    }

    // 2. Try to restore session (Silent Sign In)
    // In v7, 'attemptLightweightAuthentication' replaces 'signInSilently'
    try {
      _cachedAccount = await _googleSignIn.attemptLightweightAuthentication();
    } catch (e) {
      if (kDebugMode) print("Silent auth failed: $e");
    }

    // 3. If no account found, return null (User must explicitly login)
    if (_cachedAccount == null) {
      return null;
    }

    // 4. Create the authenticated client
    _cachedClient = _WebGoogleHttpClient(_cachedAccount!);
    return _cachedClient;
  }

  // ================== Sign Out ==================
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _cachedClient = null;
      _cachedAccount = null;
      if (kDebugMode) print("User Signed Out from Google");
    } catch (e) {
      if (kDebugMode) print("SignOut Error: $e");
    }
  }

  // ================== Helpers ==================
  /// This is used by AuthRemoteDataSource to perform the explicit sign-in
  Future<GoogleSignInAccount?> signIn() async {
    try {
      // In v7, 'authenticate' replaces 'signIn'
      // We pass scopeHint to suggest getting permissions upfront
      final account = await _googleSignIn.authenticate(scopeHint: _scopes);

      _cachedAccount = account;
      _cachedClient = _WebGoogleHttpClient(account);

      return account;
    } catch (e) {
      if (kDebugMode) print("Sign In Error: $e");
      // If the user cancels the popup, it might throw an error or return null depending on platform
      return null;
    }
  }
}

// ================== Validates & Injects Headers ==================
class _WebGoogleHttpClient extends http.BaseClient {
  final GoogleSignInAccount _account;
  final http.Client _inner = http.Client();

  // Define scopes again here or make them public in the parent class
  static const List<String> _scopes = [
    'email',
    'profile',
    'openid',
    SheetsApi.spreadsheetsScope,
    GmailApi.gmailSendScope,
    GmailApi.gmailReadonlyScope,
  ];

  _WebGoogleHttpClient(this._account);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // In v7, we access 'authorizationClient' from the account,
    // then ask for 'authorizationHeaders' for specific scopes.
    // This method handles token refresh automatically.
    final Map<String, String>? authHeaders = await _account.authorizationClient
        .authorizationHeaders(_scopes);

    if (authHeaders != null) {
      request.headers.addAll(authHeaders);
    } else {
      // Ideally, handle this case (e.g., throw exception to trigger re-login)
      if (kDebugMode) print("Failed to get fresh auth headers");
    }

    return _inner.send(request);
  }
}

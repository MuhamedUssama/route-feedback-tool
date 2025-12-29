import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:mentor_assistant/features/auth/data/models/credentials_model.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // Cache for the authenticated client and account
  http.Client? _cachedClient;
  GoogleSignInAccount? _cachedAccount;

  // Completer to handle concurrent login requests (Race Condition Prevention)
  Completer<(http.Client?, GoogleSignInAccount?)>? _loginCompleter;

  // ================== Main Entry Point (for APIs) ==================
  Future<http.Client?> getAuthenticatedClient() async {
    if (_cachedClient != null) {
      return _cachedClient;
    }

    if (_loginCompleter != null) {
      final (client, _) = await _loginCompleter!.future;
      return client;
    }

    _loginCompleter = Completer<(http.Client?, GoogleSignInAccount?)>();

    try {
      http.Client? client;
      GoogleSignInAccount? account;

      if (Platform.isMacOS) {
        final (c, a) = await _signInMacOS();
        client = c;
        account = a;
      } else if (Platform.isWindows) {
        client = await _signInWindows();
        account = null;
      } else {
        throw UnimplementedError("Platform not supported");
      }

      _cachedClient = client;
      _cachedAccount = account;

      _loginCompleter!.complete((client, account));
    } catch (e) {
      _loginCompleter!.completeError(e);
      rethrow;
    } finally {
      _loginCompleter = null;
    }

    return _cachedClient;
  }

  // ================== New Entry Point (for getting user info) ==================
  Future<(http.Client?, GoogleSignInAccount?)>
  getAuthenticatedClientAndAccount() async {
    await getAuthenticatedClient(); // Ensures login happens if needed

    return (_cachedClient, _cachedAccount);
  }

  // ================== Sign Out ==================
  Future<void> signOut() async {
    try {
      if (Platform.isMacOS) {
        await GoogleSignIn.instance.signOut();
        if (kDebugMode) print("MacOS User Signed Out");
      }

      _cachedClient?.close();
    } catch (e) {
      if (kDebugMode) print("SignOut Error: $e");
    } finally {
      _cachedClient = null;
      _cachedAccount = null;
      _loginCompleter = null;
      if (kDebugMode) print("Local Session Cleared");
    }
  }

  // ================== macOS Logic (Native v7+) ==================
  Future<(http.Client, GoogleSignInAccount)> _signInMacOS() async {
    try {
      final googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize(clientId: dotenv.env['AppleClientId']);

      final account = await googleSignIn.authenticate(scopeHint: _scopes);

      if (kDebugMode) {
        print("✅ Sign In Success: ${account.email}");
      }

      return (_MacGoogleHttpClient(account), account);
    } catch (e) {
      if (kDebugMode) print("MacOS Sign In Error: $e");
      rethrow;
    }
  }

  // ================== Windows Logic (Browser Flow) ==================
  Future<http.Client?> _signInWindows() async {
    try {
      final clientId = ClientId(
        dotenv.env['WindowsClientId']!,
        dotenv.env['WindowsClientSecret'],
      );

      final client = await clientViaUserConsent(clientId, _scopes, (url) async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (kDebugMode) print("Please go to: $url");
        }
      });

      return client;
    } catch (e) {
      if (kDebugMode) print("Windows Sign In Error: $e");
      return null;
    }
  }

  // ================== Silent Sign In (Refresh Token) ==================
  Future<(http.Client?, GoogleSignInAccount?)> signInSilently(
    CredentialsModel? credentialsModel,
  ) async {
    if (_cachedClient != null) {
      return (_cachedClient, _cachedAccount);
    }

    try {
      http.Client? client;
      GoogleSignInAccount? account;

      if (Platform.isMacOS) {
        // macOS uses GoogleSignIn for silent login
        final googleSignIn = GoogleSignIn.instance;
        // Ensure initialized with client ID
        await googleSignIn.initialize(clientId: dotenv.env['AppleClientId']);

        account = await googleSignIn.attemptLightweightAuthentication();
        if (account != null) {
          client = _MacGoogleHttpClient(account);
        }
      } else if (Platform.isWindows && credentialsModel != null) {
        // Windows uses stored credentials to recreate the client
        final clientId = ClientId(
          dotenv.env['WindowsClientId']!,
          dotenv.env['WindowsClientSecret'],
        );

        final credentials = credentialsModel.toAccessCredentials();

        // Check if credentials are valid or can be refreshed
        if (credentials.accessToken.hasExpired &&
            credentials.refreshToken == null) {
          throw Exception("Token expired and no refresh token available");
        }

        client = autoRefreshingClient(clientId, credentials, http.Client());
      }

      if (client != null) {
        _cachedClient = client;
        _cachedAccount = account;
        if (kDebugMode) print("✅ Silent Sign In Success");
      }

      return (client, account);
    } catch (e) {
      if (kDebugMode) print("Silent Sign In Error: $e");
      return (null, null);
    }
  }
}

// ================== Helper for Mac (Handles Refresh v7 Style) ==================
class _MacGoogleHttpClient extends http.BaseClient {
  final GoogleSignInAccount _account;
  final http.Client _inner = http.Client();

  static const List<String> _scopes = [
    SheetsApi.spreadsheetsScope,
    GmailApi.gmailSendScope,
  ];

  _MacGoogleHttpClient(this._account);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final Map<String, String>? authHeaders = await _account.authorizationClient
        .authorizationHeaders(_scopes);

    if (authHeaders != null) {
      request.headers.addAll(authHeaders);
    } else {
      throw Exception('Failed to get authorization headers');
    }

    return _inner.send(request);
  }
}

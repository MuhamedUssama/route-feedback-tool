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
import 'package:url_launcher/url_launcher.dart';

@lazySingleton
class GoogleAuthClient {
  static const List<String> _scopes = [
    'email',
    'profile',
    'openid',
    SheetsApi.spreadsheetsScope,
    GmailApi.gmailSendScope,
  ];

  // Cache for the authenticated client
  http.Client? _cachedClient;
  // Completer to handle concurrent login requests (Race Condition Prevention)
  Completer<http.Client?>? _loginCompleter;

  // ================== Main Entry Point ==================
  Future<http.Client?> getAuthenticatedClient() async {
    // 1. Return cached client if available
    if (_cachedClient != null) {
      return _cachedClient;
    }

    // 2. If a login is already in progress, wait for it
    if (_loginCompleter != null) {
      return _loginCompleter!.future;
    }

    // 3. Start new login flow
    _loginCompleter = Completer<http.Client?>();

    try {
      http.Client? client;
      if (Platform.isMacOS) {
        client = await _signInMacOS();
      } else if (Platform.isWindows) {
        client = await _signInWindows();
      } else {
        throw UnimplementedError("Platform not supported");
      }

      if (client != null) {
        _cachedClient = client;
        _loginCompleter!.complete(client);
      } else {
        _loginCompleter!.complete(null);
      }
    } catch (e) {
      _loginCompleter!.completeError(e);
      _loginCompleter = null; // Reset on error
      rethrow;
    } finally {
      _loginCompleter = null; // Reset after completion
    }

    return _cachedClient;
  }

  Future<void> signOut() async {
    try {
      // 1. MacOS Native Sign Out
      if (Platform.isMacOS) {
        await GoogleSignIn.instance.signOut();
        if (kDebugMode) print("MacOS User Signed Out");
      }

      // 2. Windows & General Cleanup
      if (_cachedClient != null) {
        _cachedClient!.close();
      }
    } catch (e) {
      if (kDebugMode) print("SignOut Error: $e");
    } finally {
      // 3. Global Reset
      _cachedClient = null;
      _loginCompleter = null;

      if (kDebugMode) print("Local Session Cleared");
    }
  }

  // ================== macOS Logic (Native v7) ==================
  Future<http.Client?> _signInMacOS() async {
    try {
      final googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize(clientId: dotenv.env['AppleClientId']);

      final account = await googleSignIn.authenticate();

      return _MacGoogleHttpClient(account);
    } catch (e) {
      if (kDebugMode) print("MacOS Sign In Error: $e");
      return null;
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
}

// ================== Helper for Mac (Handles Refresh v7 Style) ==================
class _MacGoogleHttpClient extends http.BaseClient {
  final GoogleSignInAccount _account;
  final http.Client _inner = http.Client();

  static const List<String> _scopes = [
    'email',
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
    }

    return _inner.send(request);
  }
}

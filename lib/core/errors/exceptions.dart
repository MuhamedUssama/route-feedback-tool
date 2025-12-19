import 'auth_error_type.dart';

abstract class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const AppException(this.message, [this.stackTrace]);

  @override
  String toString() =>
      '$runtimeType: $message${stackTrace != null ? '\n$stackTrace' : ''}';
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException(
    String message, {
    this.statusCode,
    StackTrace? stackTrace,
  }) : super(message, stackTrace);
}

class GoogleAuthException extends AppException {
  final AuthErrorType type;
  const GoogleAuthException(super.message, this.type, [super.stackTrace]);
}

class NetworkException extends AppException {
  const NetworkException([
    super.message = 'No internet connection',
    super.stackTrace,
  ]);
}

class SheetException extends AppException {
  const SheetException(super.message, [super.stackTrace]);
}

class SheetNotFoundException extends SheetException {
  const SheetNotFoundException({StackTrace? stackTrace})
    : super('Sheet not found', stackTrace);
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException({StackTrace? stackTrace})
    : super('Permission denied', stackTrace);
}

class CacheException extends AppException {
  const CacheException(super.message, [super.stackTrace]);
}

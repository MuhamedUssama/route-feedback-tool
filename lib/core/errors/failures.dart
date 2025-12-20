import 'package:freezed_annotation/freezed_annotation.dart';
import 'auth_error_type.dart';

part 'failures.freezed.dart';

@freezed
abstract class Failure with _$Failure {
  const Failure._();
  const factory Failure.server(String message, {int? statusCode}) =
      ServerFailure;
  const factory Failure.network(String message) = NetworkFailure;
  const factory Failure.auth(String message, AuthErrorType type) = AuthFailure;
  const factory Failure.sheet(String message, {String? sheetId}) = SheetFailure;
  const factory Failure.permission(String message) = PermissionFailure;
  const factory Failure.cache(String message) = CacheFailure;
  const factory Failure.unexpected(String message, {dynamic error}) =
      UnexpectedFailure;
}

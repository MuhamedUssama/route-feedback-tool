import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:json_annotation/json_annotation.dart';

part 'credentials_model.g.dart';

@JsonSerializable()
class CredentialsModel {
  final String accessToken;
  final String? refreshToken;
  final String? idToken;
  final List<String> scopes;
  final String tokenType;
  final String expiryDate; // ISO-8601 String

  CredentialsModel({
    required this.accessToken,
    this.refreshToken,
    this.idToken,
    this.scopes = const [],
    this.tokenType = 'Bearer',
    required this.expiryDate,
  });

  factory CredentialsModel.fromJson(Map<String, dynamic> json) =>
      _$CredentialsModelFromJson(json);

  Map<String, dynamic> toJson() => _$CredentialsModelToJson(this);

  /// Factory to convert from googleapis_auth AccessCredentials
  factory CredentialsModel.fromAccessCredentials(
    AccessCredentials credentials,
  ) {
    return CredentialsModel(
      accessToken: credentials.accessToken.data,
      refreshToken: credentials.refreshToken,
      idToken: credentials.idToken,
      scopes: credentials.scopes,
      tokenType: credentials.accessToken.type,
      expiryDate: credentials.accessToken.expiry.toIso8601String(),
    );
  }

  /// Convert back to AccessCredentials
  AccessCredentials toAccessCredentials() {
    return AccessCredentials(
      AccessToken(tokenType, accessToken, DateTime.parse(expiryDate)),
      refreshToken,
      scopes,
      idToken: idToken,
    );
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credentials_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CredentialsModel _$CredentialsModelFromJson(Map<String, dynamic> json) =>
    CredentialsModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      idToken: json['idToken'] as String?,
      scopes:
          (json['scopes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiryDate: json['expiryDate'] as String,
    );

Map<String, dynamic> _$CredentialsModelToJson(CredentialsModel instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'idToken': instance.idToken,
      'scopes': instance.scopes,
      'tokenType': instance.tokenType,
      'expiryDate': instance.expiryDate,
    };

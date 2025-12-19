class UserEntity {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String accessToken;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.accessToken,
  });
}

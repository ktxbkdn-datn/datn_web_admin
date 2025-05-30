class AuthEntity {
  final String accessToken;
  final String refreshToken;
  final int id;
  final String type;

  AuthEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.id,
    required this.type,
  });
}
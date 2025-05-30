class AuthModel {
  final String accessToken;
  final String refreshToken;
  final int id;
  final String type;

  AuthModel({
    required this.accessToken,
    required this.refreshToken,
    required this.id,
    required this.type,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('access_token') || json['access_token'] == null) {
      throw FormatException('Missing or invalid access_token');
    }
    if (!json.containsKey('refresh_token') || json['refresh_token'] == null) {
      throw FormatException('Missing or invalid refresh_token');
    }
    if (!json.containsKey('id') || json['id'] == null) {
      throw FormatException('Missing or invalid id');
    }
    if (!json.containsKey('type') || json['type'] == null) {
      throw FormatException('Missing or invalid type');
    }

    return AuthModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      id: json['id'] as int,
      type: json['type'] as String,
    );
  }
}
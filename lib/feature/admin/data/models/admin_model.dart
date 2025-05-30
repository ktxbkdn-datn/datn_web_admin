// lib/src/features/admin/data/models/admin_model.dart
class AdminModel {
  final int adminId;
  final String username;
  final String? fullName;
  final String? email;
  final String? phone;
  final DateTime createdAt;
  final String? resetToken;
  final String? resetTokenExpiry;
  final int resetAttempts;

  AdminModel({
    required this.adminId,
    required this.username,
    this.fullName,
    this.email,
    this.phone,
    required this.createdAt,
    this.resetToken,
    this.resetTokenExpiry,
    required this.resetAttempts,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      adminId: json['admin_id'] as int,
      username: json['username'] as String,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      resetToken: json['reset_token'] as String?,
      resetTokenExpiry: json['reset_token_expiry'] as String?,
      resetAttempts: json['reset_attempts'] as int? ?? 0,
    );
  }
}
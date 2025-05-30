import 'package:equatable/equatable.dart';

class AdminEntity extends Equatable {
  final int adminId;
  final String username;
  final String? fullName;
  final String? email;
  final String? phone;
  final DateTime? createdAt;
  final String? resetToken;
  final String? resetTokenExpiry;
  final int resetAttempts;

  const AdminEntity({
    required this.adminId,
    required this.username,
    this.fullName,
    this.email,
    this.phone,
    this.createdAt,
    this.resetToken,
    this.resetTokenExpiry,
    required this.resetAttempts,
  });

  Map<String, dynamic> toJson() {
    return {
      'adminId': adminId,
      'username': username,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'createdAt': createdAt?.toIso8601String(),
      'resetToken': resetToken,
      'resetTokenExpiry': resetTokenExpiry,
      'resetAttempts': resetAttempts,
    };
  }

  factory AdminEntity.fromJson(Map<String, dynamic> json) {
    return AdminEntity(
      adminId: json['adminId'] as int,
      username: json['username'] as String,
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      resetToken: json['resetToken'] as String?,
      resetTokenExpiry: json['resetTokenExpiry'] as String?,
      resetAttempts: json['resetAttempts'] as int,
    );
  }

  @override
  List<Object?> get props => [
    adminId,
    username,
    fullName,
    email,
    phone,
    createdAt,
    resetToken,
    resetTokenExpiry,
    resetAttempts,
  ];
}
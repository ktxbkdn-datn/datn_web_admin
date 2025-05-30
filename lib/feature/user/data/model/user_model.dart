// lib/src/features/user/data/models/user_model.dart
import '../../domain/entities/user_entity.dart';

class UserModel {
  final int userId;
  final String fullname;
  final String email;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? cccd;
  final String? className;
  final DateTime createdAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final int version;

  UserModel({
    required this.userId,
    required this.fullname,
    required this.email,
    this.phone,
    this.dateOfBirth,
    this.cccd,
    this.className,
    required this.createdAt,
    required this.isDeleted,
    this.deletedAt,
    required this.version,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as int,
      fullname: json['fullname'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth'] as String) : null,
      cccd: json['CCCD'] as String?,
      className: json['class_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isDeleted: json['is_deleted'] as bool,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
      version: json['version'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'fullname': fullname,
      'email': email,
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'CCCD': cccd,
      'class_name': className,
      'created_at': createdAt.toIso8601String(),
      'is_deleted': isDeleted,
      'deleted_at': deletedAt?.toIso8601String(),
      'version': version,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      fullname: fullname,
      email: email,
      phone: phone,
      dateOfBirth: dateOfBirth,
      cccd: cccd,
      className: className,
      createdAt: createdAt,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
      version: version,
    );
  }
}
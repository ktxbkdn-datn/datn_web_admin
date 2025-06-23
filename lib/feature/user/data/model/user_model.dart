// lib/src/features/user/data/models/user_model.dart
import 'package:intl/intl.dart';
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
  final String? hometown;
  final String? studentCode;

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
    this.hometown,
    this.studentCode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null) return null;
      try {
        // Try dd-MM-yyyy first
        return DateFormat('dd-MM-yyyy').parseStrict(dateStr);
      } catch (_) {
        try {
          // Try ISO 8601 fallback
          return DateTime.parse(dateStr);
        } catch (_) {
          return null;
        }
      }
    }
    return UserModel(
      userId: json['user_id'] as int,
      fullname: json['fullname'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      dateOfBirth: parseDate(json['date_of_birth'] as String?),
      cccd: json['CCCD'] as String?,
      className: json['class_name'] as String?,
      createdAt: parseDate(json['created_at'] as String) ?? DateTime.now(),
      isDeleted: json['is_deleted'] as bool,
      deletedAt: parseDate(json['deleted_at'] as String?),
      version: json['version'] as int,
      hometown: json['hometown'] as String?,
      studentCode: json['student_code'] as String?,
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
      'hometown': hometown,
      'student_code': studentCode,
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
      hometown: hometown,
      studentCode: studentCode,
    );
  }
}
// lib/src/features/user/domain/entities/user_entity.dart
class UserEntity {
  final int userId;
  final String fullname;
  final String email;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? cccd;
  final String? className;
  final String? hometown;       // thêm
  final String? studentCode;    // thêm
  final DateTime createdAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final int version;

  const UserEntity({
    required this.userId,
    required this.fullname,
    required this.email,
    this.phone,
    this.dateOfBirth,
    this.cccd,
    this.className,
    this.hometown,        // thêm
    this.studentCode,     // thêm
    required this.createdAt,
    required this.isDeleted,
    this.deletedAt,
    required this.version,
  });
}
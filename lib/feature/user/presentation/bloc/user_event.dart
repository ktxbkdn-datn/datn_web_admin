import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class FetchUsersEvent extends UserEvent {
  final int page;
  final int limit;
  final String? keyword; // Thêm dòng này
  final String? email;
  final String? fullname;
  final String? phone;
  final String? className;
  final String? hometown;        // thêm
  final String? studentCode;     // thêm

  const FetchUsersEvent({
    required this.page,
    required this.limit,
    this.keyword, // Thêm dòng này
    this.email,
    this.fullname,
    this.phone,
    this.className,
    this.hometown,        // thêm
    this.studentCode,     // thêm
  });

  @override
  List<Object?> get props => [page, limit, keyword, email, fullname, phone, className, hometown, studentCode];
}

class CreateUserEvent extends UserEvent {
  final String email;
  final String fullname;
  final String? phone;
  final String? hometown;        // thêm
  final String? studentCode;     // thêm

  const CreateUserEvent({
    required this.email,
    required this.fullname,
    this.phone,
    this.hometown,        // thêm
    this.studentCode,     // thêm
  });

  @override
  List<Object?> get props => [email, fullname, phone, hometown, studentCode];
}

class UpdateUserEvent extends UserEvent {
  final int userId;
  final String? fullname;
  final String? email;
  final String? phone;
  final String? cccd;
  final DateTime? dateOfBirth;
  final String? className;
  final String? hometown;        // thêm
  final String? studentCode;     // thêm

  const UpdateUserEvent({
    required this.userId,
    this.fullname,
    this.email,
    this.phone,
    this.cccd,
    this.dateOfBirth,
    this.className,
    this.hometown,        // thêm
    this.studentCode,     // thêm
  });

  @override
  List<Object?> get props => [userId, fullname, email, phone, cccd, dateOfBirth, className, hometown, studentCode];
}

class DeleteUserEvent extends UserEvent {
  final int userId;

  const DeleteUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
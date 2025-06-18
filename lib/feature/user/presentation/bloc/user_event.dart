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

  const FetchUsersEvent({
    required this.page,
    required this.limit,
    this.keyword, // Thêm dòng này
    this.email,
    this.fullname,
    this.phone,
    this.className,
  });

  @override
  List<Object?> get props => [page, limit, keyword, email, fullname, phone, className];
}

class CreateUserEvent extends UserEvent {
  final String email;
  final String fullname;
  final String? phone;

  const CreateUserEvent({
    required this.email,
    required this.fullname,
    this.phone,
  });

  @override
  List<Object?> get props => [email, fullname, phone];
}

class UpdateUserEvent extends UserEvent {
  final int userId;
  final String? fullname;
  final String? email;
  final String? phone;
  final String? cccd;
  final DateTime? dateOfBirth;
  final String? className;

  const UpdateUserEvent({
    required this.userId,
    this.fullname,
    this.email,
    this.phone,
    this.cccd,
    this.dateOfBirth,
    this.className,
  });

  @override
  List<Object?> get props => [userId, fullname, email, phone, cccd, dateOfBirth, className];
}

class DeleteUserEvent extends UserEvent {
  final int userId;

  const DeleteUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
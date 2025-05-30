// lib/src/features/user/presentation/bloc/user_event.dart
abstract class UserEvent {}

class FetchUsersEvent extends UserEvent {
  final int page;
  final int limit;
  final String? email;
  final String? fullname;
  final String? phone;
  final String? className;

  FetchUsersEvent({
    this.page = 1,
    this.limit = 10,
    this.email,
    this.fullname,
    this.phone,
    this.className,
  });
}

class CreateUserEvent extends UserEvent {
  final String email;
  final String fullname;
  final String? phone;

  CreateUserEvent({
    required this.email,
    required this.fullname,
    this.phone,
  });
}

class UpdateUserEvent extends UserEvent {
  final int userId;
  final String? fullname;
  final String? email;
  final String? phone;
  final String? cccd;
  final DateTime? dateOfBirth;
  final String? className;

  UpdateUserEvent({
    required this.userId,
    this.fullname,
    this.email,
    this.phone,
    this.cccd,
    this.dateOfBirth,
    this.className,
  });
}

class DeleteUserEvent extends UserEvent {
  final int userId;

  DeleteUserEvent(this.userId);
}

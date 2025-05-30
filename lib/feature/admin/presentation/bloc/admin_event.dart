// lib/src/features/admin/presentation/bloc/admin_event.dart
abstract class AdminEvent {}

class FetchAllAdminsEvent extends AdminEvent {
  final int page;
  final int limit;

  FetchAllAdminsEvent({this.page = 1, this.limit = 10});
}

class FetchAdminByIdEvent extends AdminEvent {
  final int adminId;

  FetchAdminByIdEvent(this.adminId);
}

class FetchCurrentAdminEvent extends AdminEvent {
  final int adminId;

  FetchCurrentAdminEvent(this.adminId);
}

class CreateAdminEvent extends AdminEvent {
  final String username;
  final String password;
  final String email;
  final String? fullName;
  final String? phone;

  CreateAdminEvent({
    required this.username,
    required this.password,
    required this.email,
    this.fullName,
    this.phone,
  });
}

class UpdateAdminEvent extends AdminEvent {
  final int adminId;
  final String? fullName;
  final String? email;
  final String? phone;

  UpdateAdminEvent({
    required this.adminId,
    this.fullName,
    this.email,
    this.phone,
  });
}

class DeleteAdminEvent extends AdminEvent {
  final int adminId;

  DeleteAdminEvent(this.adminId);
}

class RequestPasswordResetEvent extends AdminEvent {
  final String email;

  RequestPasswordResetEvent(this.email);
}

class ConfirmResetPasswordEvent extends AdminEvent {
  final String email;
  final String newPassword;
  final String code;

  ConfirmResetPasswordEvent({
    required this.email,
    required this.newPassword,
    required this.code,
  });
}

class ChangePasswordEvent extends AdminEvent {
  final String currentPassword;
  final String newPassword;

  ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });
}
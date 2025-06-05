import 'package:flutter/material.dart';

abstract class AuthEvent {}

class AdminUsernameChanged extends AuthEvent {
  final String username;

  AdminUsernameChanged(this.username);
}

class PasswordChanged extends AuthEvent {
  final String password;

  PasswordChanged(this.password);
}

class AdminLoginSubmitted extends AuthEvent {
  final String username;
  final String password;
  final bool rememberMe; // Thêm thuộc tính rememberMe
  final BuildContext? context;

  AdminLoginSubmitted({
    required this.username,
    required this.password,
    required this.rememberMe,
    this.context,
  });
}

class LogoutSubmitted extends AuthEvent {}

class ForgotPasswordEmailChanged extends AuthEvent {
  final String email;

  ForgotPasswordEmailChanged(this.email);
}

class ForgotPasswordSubmitted extends AuthEvent {
  final String email;

  ForgotPasswordSubmitted(this.email);
}

class ResetPasswordCodeChanged extends AuthEvent {
  final String code;

  ResetPasswordCodeChanged(this.code);
}

class ResetPasswordNewPasswordChanged extends AuthEvent {
  final String newPassword;

  ResetPasswordNewPasswordChanged(this.newPassword);
}

class ResetPasswordSubmitted extends AuthEvent {
  final String email;
  final String newPassword;
  final String code;

  ResetPasswordSubmitted({
    required this.email,
    required this.newPassword,
    required this.code,
  });
}

class RefreshTokenRequested extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {} // Thêm sự kiện để kiểm tra trạng thái đăng nhập
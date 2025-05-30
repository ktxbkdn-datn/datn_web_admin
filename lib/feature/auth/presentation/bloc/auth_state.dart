// lib/src/features/auth/presentation/bloc/auth_state.dart
import 'package:equatable/equatable.dart';
import 'package:datn_web_admin/feature/admin/domain/entities/admin_entity.dart';
import '../../domain/entities/auth_entity.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final AuthEntity? auth;
  final AdminEntity? admin;
  final String? error;
  final String? successMessage;

  const AuthState({
    this.isLoading = false,
    this.auth,
    this.admin,
    this.error,
    this.successMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    AuthEntity? auth,
    AdminEntity? admin,
    String? error,
    String? successMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      auth: auth ?? this.auth,
      admin: admin ?? this.admin,
      error: error,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    auth,
    admin,
    error,
    successMessage,
  ];
}

// Định nghĩa AuthFailure trong auth_state.dart
class AuthFailure implements Exception {
  final String message;

  AuthFailure(this.message);

  @override
  String toString() => message;
}
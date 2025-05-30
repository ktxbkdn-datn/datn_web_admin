// lib/src/features/user/presentation/bloc/user_state.dart
import '../../domain/entities/user_entity.dart';

class UserState {
  final List<UserEntity> users;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const UserState({
    this.users = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  UserState copyWith({
    List<UserEntity>? users,
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return UserState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}
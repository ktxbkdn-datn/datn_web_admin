import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<UserEntity> users;
  final int totalItems;

  const UserLoaded({required this.users, required this.totalItems});

  @override
  List<Object?> get props => [users, totalItems];
}

class UserCreated extends UserState {
  final UserEntity user;

  const UserCreated({required this.user});

  @override
  List<Object?> get props => [user];
}

class UserUpdated extends UserState {
  final UserEntity user;

  const UserUpdated({required this.user});

  @override
  List<Object?> get props => [user];
}

class UserDeleted extends UserState {
  final int userId;

  const UserDeleted({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UserError extends UserState {
  final String message;

  const UserError({required this.message});

  @override
  List<Object?> get props => [message];
}
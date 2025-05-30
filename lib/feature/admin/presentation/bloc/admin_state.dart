import 'package:equatable/equatable.dart';

import '../../../../src/core/error/failures.dart';
import '../../domain/entities/admin_entity.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {
  final bool isLoading;

  const AdminLoading({this.isLoading = true});

  @override
  List<Object?> get props => [isLoading];
}

class AdminListLoaded extends AdminState {
  final List<AdminEntity> admins;

  const AdminListLoaded({required this.admins});

  @override
  List<Object?> get props => [admins];
}

class AdminDeleted extends AdminState {
  final List<AdminEntity> admins;
  final String successMessage;

  const AdminDeleted({required this.admins, required this.successMessage});

  @override
  List<Object?> get props => [admins, successMessage];
}

class AdminUpdated extends AdminState {
  final AdminEntity currentAdmin;
  final String successMessage;

  const AdminUpdated({required this.currentAdmin, required this.successMessage});

  @override
  List<Object?> get props => [currentAdmin, successMessage];
}

class AdminCreated extends AdminState {
  final String successMessage;

  const AdminCreated({required this.successMessage});

  @override
  List<Object?> get props => [successMessage];
}

class AdminPasswordChanged extends AdminState {
  final String successMessage;

  const AdminPasswordChanged({required this.successMessage});

  @override
  List<Object?> get props => [successMessage];
}

class AdminError extends AdminState {
  final Failure failure;

  const AdminError({required this.failure});

  @override
  List<Object?> get props => [failure];
}
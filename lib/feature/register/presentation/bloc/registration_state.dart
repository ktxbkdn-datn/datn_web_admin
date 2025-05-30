import 'package:equatable/equatable.dart';

import '../../domain/entity/register_entity.dart';

abstract class RegistrationState extends Equatable {
  const RegistrationState();

  @override
  List<Object?> get props => [];
}

class RegistrationInitial extends RegistrationState {}

class RegistrationLoading extends RegistrationState {}

class RegistrationsLoaded extends RegistrationState {
  final List<Registration> registrations;
  final int total;
  final int pages;
  final int currentPage;

  const RegistrationsLoaded({
    required this.registrations,
    required this.total,
    required this.pages,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [registrations, total, pages, currentPage];
}

class RegistrationDetailLoaded extends RegistrationState {
  final Registration registration;

  const RegistrationDetailLoaded(this.registration);

  @override
  List<Object?> get props => [registration];
}

class RegistrationUpdated extends RegistrationState {
  final Registration registration;

  const RegistrationUpdated(this.registration);

  @override
  List<Object?> get props => [registration];
}

class RegistrationsDeleted extends RegistrationState {
  final List<int> deletedIds;
  final List<Map<String, dynamic>> errors;
  final String? message;

  const RegistrationsDeleted({
    required this.deletedIds,
    required this.errors,
    this.message,
  });

  @override
  List<Object?> get props => [deletedIds, errors, message];
}

class RegistrationError extends RegistrationState {
  final String message;

  const RegistrationError(this.message);

  @override
  List<Object?> get props => [message];
}
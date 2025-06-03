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

  const RegistrationsLoaded({
    required this.registrations,
    required this.total,
  });

  @override
  List<Object?> get props => [registrations, total];
}

class RegistrationLoaded extends RegistrationState {
  final Registration registration;

  const RegistrationLoaded(this.registration);

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
  final String? message;

  const RegistrationsDeleted({
    required this.deletedIds,
    this.message,
  });

  @override
  List<Object?> get props => [deletedIds, message];
}

class RegistrationError extends RegistrationState {
  final String message;

  const RegistrationError(this.message);

  @override
  List<Object?> get props => [message];
}
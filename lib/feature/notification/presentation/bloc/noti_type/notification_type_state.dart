// lib/src/features/notification_type/presentations/bloc/notification_type_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/notification_type_entity.dart';

abstract class NotificationTypeState extends Equatable {
  const NotificationTypeState();

  @override
  List<Object> get props => [];
}

class NotificationTypeInitial extends NotificationTypeState {}

class NotificationTypeLoading extends NotificationTypeState {}

class NotificationTypesLoaded extends NotificationTypeState {
  final List<NotificationType> types;

  const NotificationTypesLoaded({required this.types});

  @override
  List<Object> get props => [types];
}

class NotificationTypeCreated extends NotificationTypeState {
  final NotificationType type;

  const NotificationTypeCreated({required this.type});

  @override
  List<Object> get props => [type];
}

class NotificationTypeUpdated extends NotificationTypeState {
  final NotificationType type;

  const NotificationTypeUpdated({required this.type});

  @override
  List<Object> get props => [type];
}

class NotificationTypeDeleted extends NotificationTypeState {
  final int typeId;

  const NotificationTypeDeleted({required this.typeId});

  @override
  List<Object> get props => [typeId];
}

class NotificationTypeError extends NotificationTypeState {
  final String message;

  const NotificationTypeError({required this.message});

  @override
  List<Object> get props => [message];
}
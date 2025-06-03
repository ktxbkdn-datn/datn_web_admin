import 'package:equatable/equatable.dart';
import '../../../domain/entities/notification_entity.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<Notification> notifications;
  final int totalItems; // Added totalItems

  const NotificationsLoaded({required this.notifications, required this.totalItems});

  @override
  List<Object> get props => [notifications, totalItems];
}

class NotificationLoaded extends NotificationState {
  final Notification notification;

  const NotificationLoaded({required this.notification});

  @override
  List<Object> get props => [notification];
}

class NotificationRecipientsLoaded extends NotificationState {
  final List<NotificationRecipient> recipients;

  const NotificationRecipientsLoaded({required this.recipients});

  @override
  List<Object> get props => [recipients];
}

class NotificationCreated extends NotificationState {
  final Notification notification;

  const NotificationCreated({required this.notification});

  @override
  List<Object> get props => [notification];
}

class NotificationUpdated extends NotificationState {
  final Notification notification;

  const NotificationUpdated({required this.notification});

  @override
  List<Object> get props => [notification];
}

class NotificationDeleted extends NotificationState {
  final int notificationId;

  const NotificationDeleted({required this.notificationId});

  @override
  List<Object> get props => [notificationId];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError({required this.message});

  @override
  List<Object> get props => [message];
}
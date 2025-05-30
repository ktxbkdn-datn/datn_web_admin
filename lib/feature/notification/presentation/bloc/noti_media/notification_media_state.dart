// lib/src/features/notification/presentation/bloc/noti_media/notification_media_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/notification_entity.dart';

abstract class NotificationMediaState extends Equatable {
  const NotificationMediaState();

  @override
  List<Object?> get props => [];
}

class NotificationMediaInitial extends NotificationMediaState {}

class NotificationMediaLoading extends NotificationMediaState {
  final int notificationId;

  const NotificationMediaLoading({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

class NotificationMediaLoaded extends NotificationMediaState {
  final int notificationId;
  final List<MediaInfo> mediaItems;

  const NotificationMediaLoaded({
    required this.notificationId,
    required this.mediaItems,
  });

  @override
  List<Object?> get props => [notificationId, mediaItems];
}

class NotificationMediaError extends NotificationMediaState {
  final int notificationId;
  final String message;

  const NotificationMediaError({
    required this.notificationId,
    required this.message,
  });

  @override
  List<Object?> get props => [notificationId, message];
}

class NotificationMediaDeleted extends NotificationMediaState {}
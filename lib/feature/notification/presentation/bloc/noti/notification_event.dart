// notification_event.dart
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class GetGeneralNotificationsEvent extends NotificationEvent {
  final int page;
  final int limit;

  const GetGeneralNotificationsEvent({
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [page, limit];
}

class GetAllNotificationsEvent extends NotificationEvent {
  final int page;
  final int limit;
  final String? targetType;

  const GetAllNotificationsEvent({
    this.page = 1,
    this.limit = 10,
    this.targetType,
  });

  @override
  List<Object?> get props => [page, limit, targetType];
}

class GetNotificationRecipientsEvent extends NotificationEvent {
  final int notificationId;
  final int page;
  final int limit;
  final bool? isRead;

  const GetNotificationRecipientsEvent({
    required this.notificationId,
    this.page = 1,
    this.limit = 10,
    this.isRead,
  });

  @override
  List<Object?> get props => [notificationId, page, limit, isRead];
}

class CreateNotificationEvent extends NotificationEvent {
  final String title;
  final String message;
  final String targetType;
  final String? email;
  final String? roomName;
  final int? areaId;
  final List<http.MultipartFile>? media;
  final List<String>? altTexts;

  const CreateNotificationEvent({
    required this.title,
    required this.message,
    required this.targetType,
    this.email,
    this.roomName,
    this.areaId,
    this.media,
    this.altTexts,
  });

  @override
  List<Object?> get props => [
    title,
    message,
    targetType,
    email,
    roomName,
    areaId,
    media,
    altTexts,
  ];
}

class UpdateNotificationEvent extends NotificationEvent {
  final int notificationId;
  final String message;
  final String? email;
  final String? roomName;
  final int? areaId;
  final List<int>? mediaIdsToDelete;
  final List<http.MultipartFile>? media;
  final List<String>? altTexts;

  const UpdateNotificationEvent({
    required this.notificationId,
    required this.message,
    this.email,
    this.roomName,
    this.areaId,
    this.mediaIdsToDelete,
    this.media,
    this.altTexts,
  });

  @override
  List<Object?> get props => [
    notificationId,
    message,
    email,
    roomName,
    areaId,
    mediaIdsToDelete,
    media,
    altTexts,
  ];
}

class DeleteNotificationEvent extends NotificationEvent {
  final int notificationId;

  const DeleteNotificationEvent({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

class SearchNotificationsEvent extends NotificationEvent {
  final int page;
  final int limit;
  final String? keyword;
  final String? startDate;
  final String? endDate;

  const SearchNotificationsEvent({
    this.page = 1,
    this.limit = 10,
    this.keyword,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [page, limit, keyword, startDate, endDate];
}

class ResetNotificationStateEvent extends NotificationEvent {
  const ResetNotificationStateEvent();

  @override
  List<Object?> get props => [];
}
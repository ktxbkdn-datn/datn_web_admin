import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

abstract class NotificationMediaEvent extends Equatable {
  const NotificationMediaEvent();

  @override
  List<Object?> get props => [];
}

class GetNotificationMediaEvent extends NotificationMediaEvent {
  final int notificationId;
  final int page;
  final int limit;
  final String? fileType;

  const GetNotificationMediaEvent({
    required this.notificationId,
    this.page = 1,
    this.limit = 10,
    this.fileType,
  });

  @override
  List<Object?> get props => [notificationId, page, limit, fileType];
}

class AddNotificationMediaEvent extends NotificationMediaEvent {
  final int notificationId;
  final List<http.MultipartFile> media;
  final List<String>? altTexts;

  const AddNotificationMediaEvent({
    required this.notificationId,
    required this.media,
    this.altTexts,
  });

  @override
  List<Object?> get props => [notificationId, media, altTexts];
}

class UpdateNotificationMediaEvent extends NotificationMediaEvent {
  final int notificationId;
  final int mediaId;
  final String? altText;
  final bool? isPrimary;
  final int? sortOrder;

  const UpdateNotificationMediaEvent({
    required this.notificationId,
    required this.mediaId,
    this.altText,
    this.isPrimary,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [notificationId, mediaId, altText, isPrimary, sortOrder];
}

class DeleteNotificationMediaEvent extends NotificationMediaEvent {
  final int notificationId;
  final int mediaId;

  const DeleteNotificationMediaEvent({
    required this.notificationId,
    required this.mediaId,
  });

  @override
  List<Object?> get props => [notificationId, mediaId];
}

class DownloadDocumentEvent extends NotificationMediaEvent {
  final String mediaUrl;
  final String filename;
  final String authToken;

  const DownloadDocumentEvent({
    required this.mediaUrl,
    required this.filename,
    required this.authToken,
  });

  @override
  List<Object?> get props => [mediaUrl, filename, authToken];
}

class ResetNotificationMediaStateEvent extends NotificationMediaEvent {
  const ResetNotificationMediaStateEvent();

  @override
  List<Object?> get props => [];
}
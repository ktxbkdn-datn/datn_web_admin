// notification_entity.dart
import 'package:equatable/equatable.dart';

class Notification extends Equatable {
  final int? notificationId;
  final String title;
  final String message;
  final String targetType;
  final String? createdAt;
  final bool isDeleted;
  final String? deletedAt;
  final List<MediaInfo>? uploadedMedia;
  final List<UploadFailure>? failedUploads;
  final List<MediaInfo>? media; // Thêm trường media

  const Notification({
    this.notificationId,
    required this.title,
    required this.message,
    required this.targetType,
    this.createdAt,
    required this.isDeleted,
    this.deletedAt,
    this.uploadedMedia,
    this.failedUploads,
    this.media,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    print('Parsing Notification: $json'); // Log dữ liệu JSON
    return Notification(
      notificationId: json['id'] as int?,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      targetType: json['target_type'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      isDeleted: json['is_deleted'] as bool? ?? false,
      deletedAt: json['deleted_at'] as String?,
      uploadedMedia: json['uploaded_media'] != null
          ? (json['uploaded_media'] as List).map((item) => MediaInfo.fromJson(item)).toList()
          : null,
      failedUploads: json['failed_uploads'] != null
          ? (json['failed_uploads'] as List).map((item) => UploadFailure.fromJson(item)).toList()
          : null,
      media: json['media'] != null
          ? (json['media'] as List).map((item) => MediaInfo.fromJson(item)).toList()
          : null, // Parse media
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': notificationId,
      'title': title,
      'message': message,
      'target_type': targetType,
      'created_at': createdAt,
      'is_deleted': isDeleted,
      'deleted_at': deletedAt,
      'uploaded_media': uploadedMedia?.map((item) => item.toJson()).toList(),
      'failed_uploads': failedUploads?.map((item) => item.toJson()).toList(),
      'media': media?.map((item) => item.toJson()).toList(), // Bao gồm media trong toJson
    };
  }

  @override
  List<Object?> get props => [
    notificationId,
    title,
    message,
    targetType,
    createdAt,
    isDeleted,
    deletedAt,
    uploadedMedia,
    failedUploads,
    media,
  ];
}

class NotificationRecipient extends Equatable {
  final int notificationId;
  final int userId;
  final bool isRead;
  final String? readAt;

  const NotificationRecipient({
    required this.notificationId,
    required this.userId,
    required this.isRead,
    this.readAt,
  });

  factory NotificationRecipient.fromJson(Map<String, dynamic> json) {
    return NotificationRecipient(
      notificationId: json['notification_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
      'user_id': userId,
      'is_read': isRead,
      'read_at': readAt,
    };
  }

  @override
  List<Object?> get props => [notificationId, userId, isRead, readAt];
}

class MediaInfo extends Equatable {
  final String filename;
  final String type;
  final int size;
  final int sortOrder;
  final String mediaUrl;
  final String? altText; // Thêm các trường khác từ backend
  final String? uploadedAt;
  final bool? isPrimary;
  final bool? isDeleted;
  final String? deletedAt;
  final int? mediaId;
  final int? notificationId;
  final String? fileType;
  final int? fileSize;

  const MediaInfo({
    required this.filename,
    required this.type,
    required this.size,
    required this.sortOrder,
    required this.mediaUrl,
    this.altText,
    this.uploadedAt,
    this.isPrimary,
    this.isDeleted,
    this.deletedAt,
    this.mediaId,
    this.notificationId,
    this.fileType,
    this.fileSize,
  });

  factory MediaInfo.fromJson(Map<String, dynamic> json) {
    return MediaInfo(
      filename: json['filename'] as String? ?? '',
      type: json['type'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      sortOrder: json['sort_order'] as int? ?? 0,
      mediaUrl: json['media_url'] as String? ?? '',
      altText: json['alt_text'] as String?,
      uploadedAt: json['uploaded_at'] as String?,
      isPrimary: json['is_primary'] as bool?,
      isDeleted: json['is_deleted'] as bool? ?? false,
      deletedAt: json['deleted_at'] as String?,
      mediaId: json['media_id'] as int?,
      notificationId: json['notification_id'] as int?,
      fileType: json['file_type'] as String?,
      fileSize: json['file_size'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'type': type,
      'size': size,
      'sort_order': sortOrder,
      'media_url': mediaUrl,
      'alt_text': altText,
      'uploaded_at': uploadedAt,
      'is_primary': isPrimary,
      'is_deleted': isDeleted,
      'deleted_at': deletedAt,
      'media_id': mediaId,
      'notification_id': notificationId,
      'file_type': fileType,
      'file_size': fileSize,
    };
  }

  @override
  List<Object?> get props => [
    filename,
    type,
    size,
    sortOrder,
    mediaUrl,
    altText,
    uploadedAt,
    isPrimary,
    isDeleted,
    deletedAt,
    mediaId,
    notificationId,
    fileType,
    fileSize,
  ];
}

class UploadFailure extends Equatable {
  final int index;
  final String error;

  const UploadFailure({
    required this.index,
    required this.error,
  });

  factory UploadFailure.fromJson(Map<String, dynamic> json) {
    return UploadFailure(
      index: json['index'] as int? ?? 0,
      error: json['error'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'error': error,
    };
  }

  @override
  List<Object> get props => [index, error];
}
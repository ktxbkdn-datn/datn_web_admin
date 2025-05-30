import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends Equatable {
  final int? notificationId;
  final String title;
  final String message;
  final String targetType;
  final String? createdAt;
  final bool isDeleted;
  final String? deletedAt;
  final List<MediaInfo>? uploadedMedia;
  final List<UploadFailure>? failedUploads;
  final List<MediaInfo>? media;

  const NotificationModel({
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

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    print('Parsing NotificationModel: $json');
    try {
      final notificationId = json['id'] as int?;
      final title = json['title'] as String? ?? '';
      final message = json['message'] as String? ?? '';
      final targetType = json['target_type'] as String? ?? '';
      final createdAt = json['created_at'] as String?;
      final isDeleted = json['is_deleted'] as bool? ?? false;
      final deletedAt = json['deleted_at'] as String?;
      final uploadedMedia = json['uploaded_media'] != null
          ? (json['uploaded_media'] as List).map((item) => MediaInfo.fromJson(item)).toList()
          : null;
      final failedUploads = json['failed_uploads'] != null
          ? (json['failed_uploads'] as List).map((item) => UploadFailure.fromJson(item)).toList()
          : null;
      final media = json['media'] != null
          ? (json['media'] as List<dynamic>).map((item) {
              if (item is Map<String, dynamic>) {
                return MediaInfo.fromJson({
                  ...item,
                  'file_type': item['file_type']?.toString() ??
                      (item['media_url'] != null &&
                              (item['media_url'].toString().toLowerCase().endsWith('.pdf') ||
                               item['media_url'].toString().toLowerCase().endsWith('.doc') ||
                               item['media_url'].toString().toLowerCase().endsWith('.docx'))
                          ? 'document'
                          : item['media_url'] != null &&
                                  (item['media_url'].toString().toLowerCase().endsWith('.mp4') ||
                                   item['media_url'].toString().toLowerCase().endsWith('.avi'))
                              ? 'video'
                              : 'image'),
                  'filename': item['filename']?.toString() ?? item['media_url']?.toString().split('/').last ?? 'unknown',
                });
              } else if (item is String) {
                return MediaInfo.fromJson({
                  'media_url': item,
                  'file_type': item.toLowerCase().endsWith('.pdf') ||
                          item.toLowerCase().endsWith('.doc') ||
                          item.toLowerCase().endsWith('.docx')
                      ? 'document'
                      : item.toLowerCase().endsWith('.mp4') || item.toLowerCase().endsWith('.avi')
                          ? 'video'
                          : 'image',
                  'filename': item.split('/').last,
                  'type': 'file', // Default value
                  'size': 0, // Default value
                  'sort_order': 0, // Default value
                });
              }
              return MediaInfo(
                filename: 'unknown',
                type: 'image',
                size: 0,
                sortOrder: 0,
                mediaUrl: item.toString(),
                fileType: 'image',
              );
            }).toList()
          : null;

      return NotificationModel(
        notificationId: notificationId,
        title: title,
        message: message,
        targetType: targetType,
        createdAt: createdAt,
        isDeleted: isDeleted,
        deletedAt: deletedAt,
        uploadedMedia: uploadedMedia,
        failedUploads: failedUploads,
        media: media,
      );
    } catch (e) {
      print('Error parsing NotificationModel: $e');
      rethrow;
    }
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
      'media': media?.map((item) => item.toJson()).toList(),
    };
  }

  Notification toEntity() {
    return Notification(
      notificationId: notificationId,
      title: title,
      message: message,
      targetType: targetType,
      createdAt: createdAt,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
      uploadedMedia: uploadedMedia,
      failedUploads: failedUploads,
      media: media,
    );
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

class NotificationRecipientModel extends Equatable {
  final int notificationId;
  final int userId;
  final bool isRead;
  final String? readAt;

  const NotificationRecipientModel({
    required this.notificationId,
    required this.userId,
    required this.isRead,
    this.readAt,
  });

  factory NotificationRecipientModel.fromJson(Map<String, dynamic> json) {
    print('Parsing NotificationRecipientModel: $json');
    try {
      final notificationId = json['notification_id'] as int? ?? 0;
      final userId = json['user_id'] as int? ?? 0;
      final isRead = json['is_read'] as bool? ?? false;
      final readAt = json['read_at'] as String?;

      return NotificationRecipientModel(
        notificationId: notificationId,
        userId: userId,
        isRead: isRead,
        readAt: readAt,
      );
    } catch (e) {
      print('Error parsing NotificationRecipientModel: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
      'user_id': userId,
      'is_read': isRead,
      'read_at': readAt,
    };
  }

  NotificationRecipient toEntity() {
    return NotificationRecipient(
      notificationId: notificationId,
      userId: userId,
      isRead: isRead,
      readAt: readAt,
    );
  }

  @override
  List<Object?> get props => [notificationId, userId, isRead, readAt];
}
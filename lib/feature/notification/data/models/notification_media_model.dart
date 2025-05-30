// lib/src/features/notification/data/models/notification_media_model.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationMediaModel extends Equatable {
  final String filename;
  final String type;
  final int size;
  final int sortOrder;
  final String mediaUrl;
  final String? altText;
  final String? uploadedAt;
  final bool? isPrimary;
  final bool? isDeleted;
  final String? deletedAt;
  final int? mediaId;
  final int? notificationId;
  final String? fileType;
  final int? fileSize;

  const NotificationMediaModel({
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

  factory NotificationMediaModel.fromJson(Map<String, dynamic> json) {
    return NotificationMediaModel(
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
      fileType: json['file_type'] as String? ??
          (json['media_url']!.toString().toLowerCase().endsWith('.pdf') ||
                  json['media_url']!.toString().toLowerCase().endsWith('.doc') ||
                  json['media_url']!.toString().toLowerCase().endsWith('.docx')
              ? 'document'
              : json['media_url']!.toString().toLowerCase().endsWith('.mp4') ||
                      json['media_url']!.toString().toLowerCase().endsWith('.avi')
                  ? 'video'
                  : 'image'),
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

  MediaInfo toEntity() {
    return MediaInfo(
      filename: filename,
      type: type,
      size: size,
      sortOrder: sortOrder,
      mediaUrl: mediaUrl,
      altText: altText,
      uploadedAt: uploadedAt,
      isPrimary: isPrimary,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
      mediaId: mediaId,
      notificationId: notificationId,
      fileType: fileType,
      fileSize: fileSize,
    );
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
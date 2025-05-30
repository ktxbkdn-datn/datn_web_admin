class NotificationMedia {
  final int mediaId;
  final int? notificationId;
  final String mediaUrl;
  final String? altText;
  final String? uploadedAt;
  final bool isPrimary;
  final int sortOrder;
  final bool isDeleted;
  final String? deletedAt;
  final String fileType;
  final int? fileSize;

  const NotificationMedia({
    required this.mediaId,
    this.notificationId,
    required this.mediaUrl,
    this.altText,
    this.uploadedAt,
    required this.isPrimary,
    required this.sortOrder,
    required this.isDeleted,
    this.deletedAt,
    required this.fileType,
    this.fileSize,
  });

  factory NotificationMedia.fromJson(Map<String, dynamic> json) {
    return NotificationMedia(
      mediaId: json['media_id'] as int,
      notificationId: json['notification_id'] as int?,
      mediaUrl: json['media_url'] as String,
      altText: json['alt_text'] as String?,
      uploadedAt: json['uploaded_at'] as String?,
      isPrimary: json['is_primary'] as bool,
      sortOrder: json['sort_order'] as int,
      isDeleted: json['is_deleted'] as bool,
      deletedAt: json['deleted_at'] as String?,
      fileType: json['file_type'] as String,
      fileSize: json['file_size'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'media_id': mediaId,
      'notification_id': notificationId,
      'media_url': mediaUrl,
      'alt_text': altText,
      'uploaded_at': uploadedAt,
      'is_primary': isPrimary,
      'sort_order': sortOrder,
      'is_deleted': isDeleted,
      'deleted_at': deletedAt,
      'file_type': fileType,
      'file_size': fileSize,
    };
  }
}
// lib/src/features/notification/domain/usecase/notification_media_use_cases.dart
import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';
import 'package:http/http.dart' as http;
import '../entities/notification_entity.dart';
import '../repository/notification_media_repository.dart';

class GetNotificationMedia {
  final NotificationMediaRepository repository;

  GetNotificationMedia(this.repository);

  Future<Either<Failure, List<MediaInfo>>> call({
    required int notificationId,
    int page = 1,
    int limit = 10,
    String? fileType,
  }) async {
    return await repository.getNotificationMedia(
      notificationId: notificationId,
      page: page,
      limit: limit,
      fileType: fileType,
    );
  }
}

class AddNotificationMedia {
  final NotificationMediaRepository repository;

  AddNotificationMedia(this.repository);

  Future<Either<Failure, List<MediaInfo>>> call({
    required int notificationId,
    required List<http.MultipartFile> media,
    List<String>? altTexts,
  }) async {
    return await repository.addNotificationMedia(
      notificationId: notificationId,
      media: media,
      altTexts: altTexts,
    );
  }
}

class UpdateNotificationMedia {
  final NotificationMediaRepository repository;

  UpdateNotificationMedia(this.repository);

  Future<Either<Failure, MediaInfo>> call({
    required int notificationId,
    required int mediaId,
    String? altText,
    bool? isPrimary,
    int? sortOrder,
  }) async {
    return await repository.updateNotificationMedia(
      notificationId: notificationId,
      mediaId: mediaId,
      altText: altText,
      isPrimary: isPrimary,
      sortOrder: sortOrder,
    );
  }
}

class DeleteNotificationMedia {
  final NotificationMediaRepository repository;

  DeleteNotificationMedia(this.repository);

  Future<Either<Failure, void>> call({
    required int mediaId,
  }) async {
    return await repository.deleteNotificationMedia(mediaId: mediaId);
  }
}
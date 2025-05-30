// lib/src/features/notification/domain/repository/notification_media_repository.dart
import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';
import 'package:http/http.dart' as http;
import '../entities/notification_entity.dart';

abstract class NotificationMediaRepository {
  Future<Either<Failure, List<MediaInfo>>> getNotificationMedia({
    required int notificationId,
    int page = 1,
    int limit = 10,
    String? fileType,
  });

  Future<Either<Failure, List<MediaInfo>>> addNotificationMedia({
    required int notificationId,
    required List<http.MultipartFile> media,
    List<String>? altTexts,
  });

  Future<Either<Failure, MediaInfo>> updateNotificationMedia({
    required int notificationId,
    required int mediaId,
    String? altText,
    bool? isPrimary,
    int? sortOrder,
  });

  Future<Either<Failure, void>> deleteNotificationMedia({
    required int mediaId,
  });
}
// lib/src/features/notification/data/repository/notification_media_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/notification_entity.dart';
import '../../domain/repository/notification_media_repository.dart';
import '../datasource/notification_media_remote_data_source.dart';


class NotificationMediaRepositoryImpl implements NotificationMediaRepository {
  final NotificationMediaRemoteDataSource remoteDataSource;

  NotificationMediaRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<MediaInfo>>> getNotificationMedia({
    required int notificationId,
    int page = 1,
    int limit = 10,
    String? fileType,
  }) async {
    final result = await remoteDataSource.getNotificationMedia(
      notificationId: notificationId,
      page: page,
      limit: limit,
      fileType: fileType,
    );
    return result.map((mediaList) => mediaList.map((media) => media.toEntity()).toList());
  }

  @override
  Future<Either<Failure, List<MediaInfo>>> addNotificationMedia({
    required int notificationId,
    required List<http.MultipartFile> media,
    List<String>? altTexts,
  }) async {
    final result = await remoteDataSource.addNotificationMedia(
      notificationId: notificationId,
      media: media,
      altTexts: altTexts,
    );
    return result.map((mediaList) => mediaList.map((media) => media.toEntity()).toList());
  }

  @override
  Future<Either<Failure, MediaInfo>> updateNotificationMedia({
    required int notificationId,
    required int mediaId,
    String? altText,
    bool? isPrimary,
    int? sortOrder,
  }) async {
    final result = await remoteDataSource.updateNotificationMedia(
      notificationId: notificationId,
      mediaId: mediaId,
      altText: altText,
      isPrimary: isPrimary,
      sortOrder: sortOrder,
    );
    return result.map((media) => media.toEntity());
  }

  @override
  Future<Either<Failure, void>> deleteNotificationMedia({
    required int mediaId,
  }) async {
    return await remoteDataSource.deleteNotificationMedia(mediaId: mediaId);
  }
}
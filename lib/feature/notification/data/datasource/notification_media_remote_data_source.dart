// lib/src/features/notification/data/datasource/notification_media_remote_data_source.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';
import 'package:datn_web_admin/src/core/network/api_client.dart';
import 'package:http/http.dart' as http;

import '../models/notification_media_model.dart';

abstract class NotificationMediaRemoteDataSource {
  Future<Either<Failure, List<NotificationMediaModel>>> getNotificationMedia({
    required int notificationId,
    int page = 1,
    int limit = 10,
    String? fileType,
  });

  Future<Either<Failure, List<NotificationMediaModel>>> addNotificationMedia({
    required int notificationId,
    required List<http.MultipartFile> media,
    List<String>? altTexts,
  });

  Future<Either<Failure, NotificationMediaModel>> updateNotificationMedia({
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

class NotificationMediaRemoteDataSourceImpl implements NotificationMediaRemoteDataSource {
  final ApiService apiService;

  NotificationMediaRemoteDataSourceImpl(this.apiService);

  @override
  Future<Either<Failure, List<NotificationMediaModel>>> getNotificationMedia({
    required int notificationId,
    int page = 1,
    int limit = 10,
    String? fileType,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (fileType != null) 'file_type': fileType,
      };
      final response = await apiService.get('/notifications/$notificationId/media', queryParams: queryParams);
      if (response is Map<String, dynamic> && response.containsKey('message')) {
        if (response['message'] == 'Không tìm thấy thông báo') {
          return Left(ServerFailure('Notification not found'));
        } else if (response['message'] == 'Bạn không có quyền truy cập media của thông báo này') {
          return Left(ServerFailure('Unauthorized access to media'));
        }
        return const Right([]);
      } else if (response is Map<String, dynamic> && response.containsKey('media')) {
        final mediaList = (response['media'] as List)
            .map((item) => NotificationMediaModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return Right(mediaList);
      } else {
        return Left(ServerFailure('Phản hồi API không hợp lệ: $response'));
      }
    } catch (e) {
      if (e is SocketException) {
        return Left(ServerFailure('Không tìm thấy media cho thông báo $notificationId - Lỗi mạng'));
      } else if (e is ServerFailure && e.message.contains('404')) {
        return const Right([]);
      } else if (e is ServerFailure && e.message.contains('405')) {
        return Left(ServerFailure('Phương thức không được phép cho endpoint /notifications/$notificationId/media'));
      } else if (e is ServerFailure && e.message.contains('403')) {
        return Left(ServerFailure('Bạn không có quyền truy cập media của thông báo $notificationId'));
      }
      return Left(ServerFailure('Lỗi khi gọi API /notifications/$notificationId/media: $e'));
    }
  }

  @override
  Future<Either<Failure, List<NotificationMediaModel>>> addNotificationMedia({
    required int notificationId,
    required List<http.MultipartFile> media,
    List<String>? altTexts,
  }) async {
    try {
      final fields = <String, String>{};
      if (altTexts != null) {
        for (int i = 0; i < altTexts.length; i++) {
          fields['alt_text_$i'] = altTexts[i];
        }
      }
      final response = await apiService.postMultipart(
        '/admin/notifications/$notificationId/media',
        fields: fields,
        files: media,
      );
      if (response is Map<String, dynamic> && response.containsKey('media')) {
        final mediaList = (response['media'] as List)
            .map((item) => NotificationMediaModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return Right(mediaList);
      } else {
        return Left(ServerFailure('Phản hồi API không hợp lệ: $response'));
      }
    } catch (e) {
      return Left(ServerFailure('Lỗi khi thêm media cho thông báo $notificationId: $e'));
    }
  }

  @override
  Future<Either<Failure, NotificationMediaModel>> updateNotificationMedia({
    required int notificationId,
    required int mediaId,
    String? altText,
    bool? isPrimary,
    int? sortOrder,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (altText != null) body['alt_text'] = altText;
      if (isPrimary != null) body['is_primary'] = isPrimary;
      if (sortOrder != null) body['sort_order'] = sortOrder;
      final response = await apiService.put('/admin/notifications/media/$mediaId', body);
      return Right(NotificationMediaModel.fromJson(response));
    } catch (e) {
      return Left(ServerFailure('Lỗi khi cập nhật media $mediaId: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotificationMedia({
    required int mediaId,
  }) async {
    try {
      final response = await apiService.delete('/admin/notifications/media/$mediaId');
      if (response is Map<String, dynamic> && response.containsKey('message')) {
        return Left(ServerFailure('Không thể xóa media: ${response['message']}'));
      }
      return const Right(null);
    } catch (e) {
      if (e.toString().contains('404') || e.toString().contains('500')) {
        return const Right(null);
      }
      return Left(ServerFailure('Lỗi khi xóa media $mediaId: $e'));
    }
  }
}
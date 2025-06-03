import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../../../src/core/error/failures.dart';
import '../../../../src/core/network/api_client.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<Either<Failure, List<NotificationModel>>> getGeneralNotifications({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, (List<NotificationModel>, int)>> getAllNotifications({
    int page = 1,
    int limit = 10,
    String? targetType,
  });

  Future<Either<Failure, List<NotificationRecipientModel>>> getNotificationRecipients({
    required int notificationId,
    int page = 1,
    int limit = 10,
    bool? isRead,
  });

  Future<Either<Failure, NotificationModel>> createNotification({
    required String title,
    required String message,
    required String targetType,
    String? email,
    String? roomName,
    int? areaId,
    List<http.MultipartFile>? media,
    List<String>? altTexts,
    List<int>? sortOrders,
  });

  Future<Either<Failure, NotificationModel>> updateNotification({
    required int notificationId,
    required String message,
    String? email,
    String? roomName,
    int? areaId,
    List<int>? mediaIdsToDelete,
    List<http.MultipartFile>? media,
    List<String>? altTexts,
    List<int>? sortOrders,
  });

  Future<Either<Failure, void>> deleteNotification({
    required int notificationId,
  });

  Future<Either<Failure, List<NotificationModel>>> searchNotifications({
    int page = 1,
    int limit = 10,
    String? keyword,
    String? startDate,
    String? endDate,
  });
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiService apiService;

  NotificationRemoteDataSourceImpl(this.apiService);

  @override
  Future<Either<Failure, List<NotificationModel>>> getGeneralNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      final response = await apiService.get('/notifications/general', queryParams: queryParams);
      final notifications = (response['notifications'] as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
      return Right(notifications);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, (List<NotificationModel>, int)>> getAllNotifications({
    int page = 1,
    int limit = 10,
    String? targetType,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (targetType != null) 'target_type': targetType,
      };
      final response = await apiService.get('/notifications', queryParams: queryParams);
      final notifications = (response['notifications'] as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
      final totalItems = response['total'] as int? ?? 0;
      return Right((notifications, totalItems));
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<NotificationRecipientModel>>> getNotificationRecipients({
    required int notificationId,
    int page = 1,
    int limit = 10,
    bool? isRead,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (isRead != null) 'is_read': isRead.toString(),
      };
      final response = await apiService.get(
        '/admin/notifications/$notificationId/recipients',
        queryParams: queryParams,
      );
      final recipients = (response['recipients'] as List)
          .map((json) => NotificationRecipientModel.fromJson(json))
          .toList();
      return Right(recipients);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, NotificationModel>> createNotification({
    required String title,
    required String message,
    required String targetType,
    String? email,
    String? roomName,
    int? areaId,
    List<http.MultipartFile>? media,
    List<String>? altTexts,
    List<int>? sortOrders,
  }) async {
    try {
      final fields = {
        'title': title,
        'message': message,
        'target_type': targetType,
        if (email != null) 'email': email,
        if (roomName != null) 'room_name': roomName,
        if (areaId != null) 'area_id': areaId.toString(),
        if (altTexts != null)
          for (int i = 0; i < altTexts.length; i++)
            'alt_text_$i': altTexts[i],
        if (sortOrders != null)
          for (int i = 0; i < sortOrders.length; i++)
            'sort_order_$i': sortOrders[i].toString(),
      };
      final files = media ?? [];
      final response = await apiService.postMultipart(
        '/admin/notifications',
        fields: fields,
        files: files,
      );
      final notification = NotificationModel.fromJson(response);
      return Right(notification);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, NotificationModel>> updateNotification({
    required int notificationId,
    required String message,
    String? email,
    String? roomName,
    int? areaId,
    List<int>? mediaIdsToDelete,
    List<http.MultipartFile>? media,
    List<String>? altTexts,
    List<int>? sortOrders,
  }) async {
    try {
      final fields = {
        'message': message,
        if (email != null) 'email': email,
        if (roomName != null) 'room_name': roomName,
        if (areaId != null) 'area_id': areaId.toString(),
        if (mediaIdsToDelete != null)
          'media_ids_to_delete': mediaIdsToDelete.join(','),
        if (altTexts != null)
          for (int i = 0; i < altTexts.length; i++)
            'alt_text_$i': altTexts[i],
        if (sortOrders != null)
          for (int i = 0; i < sortOrders.length; i++)
            'sort_order_$i': sortOrders[i].toString(),
      };
      final files = media ?? [];
      final response = await apiService.putMultipart(
        '/admin/notifications/$notificationId',
        fields: fields,
        files: files,
      );
      final notification = NotificationModel.fromJson(response);
      return Right(notification);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification({
    required int notificationId,
  }) async {
    try {
      await apiService.delete('/admin/notifications/$notificationId');
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<NotificationModel>>> searchNotifications({
    int page = 1,
    int limit = 10,
    String? keyword,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (keyword != null) 'keyword': keyword,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      };
      final response = await apiService.get(
        '/admin/notifications/search',
        queryParams: queryParams,
      );
      final notifications = (response['notifications'] as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
      return Right(notifications);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Failure _handleError(dynamic error) {
    if (error is ServerFailure) {
      return ServerFailure(error.message);
    } else if (error is NetworkFailure) {
      return NetworkFailure(error.message);
    } else {
      return ServerFailure('Lỗi không xác định: $error');
    }
  }
}
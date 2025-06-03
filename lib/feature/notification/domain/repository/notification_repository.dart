import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../../../src/core/error/failures.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<Notification>>> getGeneralNotifications({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, (List<Notification>, int)>> getAllNotifications({
    int page = 1,
    int limit = 10,
    String? targetType,
  });

  Future<Either<Failure, List<NotificationRecipient>>> getNotificationRecipients({
    required int notificationId,
    int page = 1,
    int limit = 10,
    bool? isRead,
  });

  Future<Either<Failure, Notification>> createNotification({
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

  Future<Either<Failure, Notification>> updateNotification({
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

  Future<Either<Failure, List<Notification>>> searchNotifications({
    int page = 1,
    int limit = 10,
    String? keyword,
    String? startDate,
    String? endDate,
  });
}
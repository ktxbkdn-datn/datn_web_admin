// notification_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repository/notification_repository.dart';
import 'package:http/http.dart' as http;

class CreateNotification {
  final NotificationRepository repository;

  CreateNotification(this.repository);

  Future<Either<Failure, Notification>> call({
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
    return await repository.createNotification(
      title: title,
      message: message,
      targetType: targetType,
      email: email,
      roomName: roomName,
      areaId: areaId,
      media: media,
      altTexts: altTexts,
      sortOrders: sortOrders,
    );
  }
}

class GetAllNotifications {
  final NotificationRepository repository;

  GetAllNotifications(this.repository);

  Future<Either<Failure, List<Notification>>> call({
    int page = 1,
    int limit = 10,
    String? targetType,
  }) async {
    return await repository.getAllNotifications(
      page: page,
      limit: limit,
      targetType: targetType,
    );
  }
}

class GetGeneralNotifications {
  final NotificationRepository repository;

  GetGeneralNotifications(this.repository);

  Future<Either<Failure, List<Notification>>> call({
    int page = 1,
    int limit = 10,
  }) async {
    return await repository.getGeneralNotifications(
      page: page,
      limit: limit,
    );
  }
}

class GetNotificationRecipients {
  final NotificationRepository repository;

  GetNotificationRecipients(this.repository);

  Future<Either<Failure, List<NotificationRecipient>>> call({
    required int notificationId,
    int page = 1,
    int limit = 10,
    bool? isRead,
  }) async {
    return await repository.getNotificationRecipients(
      notificationId: notificationId,
      page: page,
      limit: limit,
      isRead: isRead,
    );
  }
}

class UpdateNotification {
  final NotificationRepository repository;

  UpdateNotification(this.repository);

  Future<Either<Failure, Notification>> call({
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
    return await repository.updateNotification(
      notificationId: notificationId,
      message: message,
      email: email,
      roomName: roomName,
      areaId: areaId,
      mediaIdsToDelete: mediaIdsToDelete,
      media: media,
      altTexts: altTexts,
      sortOrders: sortOrders,
    );
  }
}

class DeleteNotification {
  final NotificationRepository repository;

  DeleteNotification(this.repository);

  Future<Either<Failure, void>> call({
    required int notificationId,
  }) async {
    return await repository.deleteNotification(notificationId: notificationId);
  }
}

class SearchNotifications {
  final NotificationRepository repository;

  SearchNotifications(this.repository);

  Future<Either<Failure, List<Notification>>> call({
    int page = 1,
    int limit = 10,
    String? keyword,
    String? startDate,
    String? endDate,
  }) async {
    return await repository.searchNotifications(
      page: page,
      limit: limit,
      keyword: keyword,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
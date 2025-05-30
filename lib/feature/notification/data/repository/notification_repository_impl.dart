// notification_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../../../src/core/error/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repository/notification_repository.dart';
import '../datasource/notification_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Notification>>> getGeneralNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final result = await remoteDataSource.getGeneralNotifications(
        page: page,
        limit: limit,
      );
      return result.map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      if (e is ServerFailure) {
        return Left(ServerFailure(e.message));
      } else if (e is NetworkFailure) {
        return Left(NetworkFailure(e.message));
      }
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Notification>>> getAllNotifications({
    int page = 1,
    int limit = 10,
    String? targetType,
  }) async {
    try {
      final result = await remoteDataSource.getAllNotifications(
        page: page,
        limit: limit,
        targetType: targetType,
      );
      return result.map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      if (e is ServerFailure) {
        return Left(ServerFailure(e.message));
      } else if (e is NetworkFailure) {
        return Left(NetworkFailure(e.message));
      }
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, List<NotificationRecipient>>> getNotificationRecipients({
    required int notificationId,
    int page = 1,
    int limit = 10,
    bool? isRead,
  }) async {
    try {
      final result = await remoteDataSource.getNotificationRecipients(
        notificationId: notificationId,
        page: page,
        limit: limit,
        isRead: isRead,
      );
      return result.map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      if (e is ServerFailure) {
        return Left(ServerFailure(e.message));
      } else if (e is NetworkFailure) {
        return Left(NetworkFailure(e.message));
      }
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
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
  }) async {
    try {
      final result = await remoteDataSource.createNotification(
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
      return result.map((model) => model.toEntity());
    } catch (e) {
      if (e is ServerFailure) {
        return Left(ServerFailure(e.message));
      } else if (e is NetworkFailure) {
        return Left(NetworkFailure(e.message));
      }
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
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
  }) async {
    try {
      final result = await remoteDataSource.updateNotification(
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
      return result.map((model) => model.toEntity());
    } catch (e) {
      if (e is ServerFailure) {
        return Left(ServerFailure(e.message));
      } else if (e is NetworkFailure) {
        return Left(NetworkFailure(e.message));
      }
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification({
    required int notificationId,
  }) async {
    try {
      final result = await remoteDataSource.deleteNotification(notificationId: notificationId);
      return result;
    } catch (e) {
      if (e is ServerFailure) {
        return Left(ServerFailure(e.message));
      } else if (e is NetworkFailure) {
        return Left(NetworkFailure(e.message));
      }
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Notification>>> searchNotifications({
    int page = 1,
    int limit = 10,
    String? keyword,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final result = await remoteDataSource.searchNotifications(
        page: page,
        limit: limit,
        keyword: keyword,
        startDate: startDate,
        endDate: endDate,
      );
      return result.map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      if (e is ServerFailure) {
        return Left(ServerFailure(e.message));
      } else if (e is NetworkFailure) {
        return Left(NetworkFailure(e.message));
      }
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }
}
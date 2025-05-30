import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../../../../src/core/network/api_client.dart';

import '../models/noti_type_model.dart';

abstract class NotificationTypeRemoteDataSource {
  Future<Either<Failure, List<NotificationTypeModel>>> getAllNotificationTypes({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, NotificationTypeModel>> createNotificationType({
    required String name,
    String? description,
    required String status,  // Thêm trường status
  });

  Future<Either<Failure, NotificationTypeModel>> updateNotificationType({
    required int typeId,
    String? name,
    String? description,
    required String status,  // Thêm trường status
  });

  Future<Either<Failure, void>> deleteNotificationType({
    required int typeId,
  });
}

class NotificationTypeRemoteDataSourceImpl implements NotificationTypeRemoteDataSource {
  final ApiService apiService;

  NotificationTypeRemoteDataSourceImpl(this.apiService);

  @override
  Future<Either<Failure, List<NotificationTypeModel>>> getAllNotificationTypes({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      final response = await apiService.get('/notification-types', queryParams: queryParams);
      final types = (response['notification_types'] as List)
          .map((json) => NotificationTypeModel.fromJson(json))
          .toList();
      return Right(types);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, NotificationTypeModel>> createNotificationType({
    required String name,
    String? description,
    required String status,
  }) async {
    try {
      final body = {
        'name': name,
        if (description != null) 'description': description,
        'status': status,  // Gửi status trong body
      };
      final response = await apiService.post('/admin/notification-types', body);
      final type = NotificationTypeModel.fromJson(response);
      return Right(type);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, NotificationTypeModel>> updateNotificationType({
    required int typeId,
    String? name,
    String? description,
    required String status,
  }) async {
    try {
      final body = {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        'status': status,  // Gửi status trong body
      };
      final response = await apiService.put('/admin/notification-types/$typeId', body);
      final type = NotificationTypeModel.fromJson(response);
      return Right(type);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotificationType({
    required int typeId,
  }) async {
    try {
      await apiService.delete('/admin/notification-types/$typeId');
      return const Right(null);
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
      return ServerFailure('Unexpected error: $error');
    }
  }
}
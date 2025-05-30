import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';

import '../entities/notification_type_entity.dart';

abstract class NotificationTypeRepository {
  Future<Either<Failure, List<NotificationType>>> getAllNotificationTypes({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, NotificationType>> createNotificationType({
    required String name,
    String? description,
    required String status,  // Thêm trường status
  });

  Future<Either<Failure, NotificationType>> updateNotificationType({
    required int typeId,
    String? name,
    String? description,
    required String status,  // Thêm trường status
  });

  Future<Either<Failure, void>> deleteNotificationType({
    required int typeId,
  });
}
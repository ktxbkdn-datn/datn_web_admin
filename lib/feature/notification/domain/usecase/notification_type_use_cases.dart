import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';

import '../entities/notification_type_entity.dart';
import '../repository/noti_type_repository.dart';

// Use case: Lấy danh sách loại thông báo
class GetAllNotificationTypes {
  final NotificationTypeRepository repository;

  GetAllNotificationTypes(this.repository);

  Future<Either<Failure, List<NotificationType>>> call({
    int page = 1,
    int limit = 10,
  }) async {
    return await repository.getAllNotificationTypes(page: page, limit: limit);
  }
}

// Use case: Tạo loại thông báo mới
class CreateNotificationType {
  final NotificationTypeRepository repository;

  CreateNotificationType(this.repository);

  Future<Either<Failure, NotificationType>> call({
    required String name,
    String? description,
    required String status,  // Thêm tham số status
  }) async {
    return await repository.createNotificationType(
      name: name,
      description: description,
      status: status,
    );
  }
}

// Use case: Cập nhật loại thông báo
class UpdateNotificationType {
  final NotificationTypeRepository repository;

  UpdateNotificationType(this.repository);

  Future<Either<Failure, NotificationType>> call({
    required int typeId,
    String? name,
    String? description,
    required String status,  // Thêm tham số status
  }) async {
    return await repository.updateNotificationType(
      typeId: typeId,
      name: name,
      description: description,
      status: status,
    );
  }
}

// Use case: Xóa loại thông báo
class DeleteNotificationType {
  final NotificationTypeRepository repository;

  DeleteNotificationType(this.repository);

  Future<Either<Failure, void>> call({
    required int typeId,
  }) async {
    return await repository.deleteNotificationType(typeId: typeId);
  }
}
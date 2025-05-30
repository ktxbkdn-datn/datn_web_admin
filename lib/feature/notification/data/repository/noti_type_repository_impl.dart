import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../../domain/entities/notification_type_entity.dart';
import '../../domain/repository/noti_type_repository.dart';
import '../datasource/noti_type_datasource.dart';

class NotificationTypeRepositoryImpl implements NotificationTypeRepository {
  final NotificationTypeRemoteDataSource remoteDataSource;

  NotificationTypeRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<NotificationType>>> getAllNotificationTypes({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final result = await remoteDataSource.getAllNotificationTypes(
        page: page,
        limit: limit,
      );
      return result.map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, NotificationType>> createNotificationType({
    required String name,
    String? description,
    required String status,  // Thêm trường status
  }) async {
    try {
      final result = await remoteDataSource.createNotificationType(
        name: name,
        description: description,
        status: status,
      );
      return result.map((model) => model.toEntity());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, NotificationType>> updateNotificationType({
    required int typeId,
    String? name,
    String? description,
    required String status,  // Thêm trường status
  }) async {
    try {
      final result = await remoteDataSource.updateNotificationType(
        typeId: typeId,
        name: name,
        description: description,
        status: status,
      );
      return result.map((model) => model.toEntity());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotificationType({
    required int typeId,
  }) async {
    try {
      final result = await remoteDataSource.deleteNotificationType(typeId: typeId);
      return result;
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
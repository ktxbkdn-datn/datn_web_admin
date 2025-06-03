import 'package:dartz/dartz.dart';

import '../../../../src/core/error/failures.dart';
import '../../domain/entity/register_entity.dart';
import '../../domain/repository/register_repository.dart';
import '../data_resource/registration_datasource.dart';

class RegistrationRepositoryImpl implements RegistrationRepository {
  final RegistrationRemoteDataSource remoteDataSource;

  RegistrationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, (List<Registration>, int)>> getAllRegistrations({
    int page = 1,
    int limit = 10,
    String? status,
    int? roomId,
    String? nameStudent,
    String? meetingDatetime,
  }) async {
    try {
      final result = await remoteDataSource.getAllRegistrations(
        page: page,
        limit: limit,
        status: status,
        roomId: roomId,
        nameStudent: nameStudent,
        meetingDatetime: meetingDatetime,
      );
      return result.map((tuple) => (
            tuple.$1.map((model) => model.toEntity()).toList(),
            tuple.$2,
          ));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, Registration>> getRegistrationById(int id) async {
    try {
      final result = await remoteDataSource.getRegistrationById(id);
      return result.map((model) => model.toEntity());
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, Registration>> updateRegistrationStatus({
    required int id,
    required String status,
    String? rejectionReason,
  }) async {
    try {
      final result = await remoteDataSource.updateRegistrationStatus(
        id: id,
        status: status,
        rejectionReason: rejectionReason,
      );
      return result.map((model) => model.toEntity());
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, Registration>> setMeetingDatetime({
    required int id,
    required DateTime meetingDatetime,
    String? meetingLocation,
  }) async {
    try {
      final result = await remoteDataSource.setMeetingDatetime(
        id: id,
        meetingDatetime: meetingDatetime,
        meetingLocation: meetingLocation,
      );
      return result.map((model) => model.toEntity());
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteRegistrationsBatch(
      List<int> registrationIds) async {
    try {
      final result = await remoteDataSource.deleteRegistrationsBatch(registrationIds);
      return result;
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }
}
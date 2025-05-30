import 'package:dartz/dartz.dart';

import '../../../../src/core/error/failures.dart';
import '../../../../src/core/network/api_client.dart';
import '../models/register_model.dart';

abstract class RegistrationRemoteDataSource {
  Future<Either<Failure, List<RegistrationModel>>> getAllRegistrations({
    int page,
    int limit,
    String? status,
    int? roomId,
    String? nameStudent,
    String? meetingDatetime,
  });

  Future<Either<Failure, RegistrationModel>> getRegistrationById(int id);

  Future<Either<Failure, RegistrationModel>> updateRegistrationStatus({
    required int id,
    required String status,
    String? rejectionReason,
  });

  Future<Either<Failure, RegistrationModel>> setMeetingDatetime({
    required int id,
    required DateTime meetingDatetime,
    String? meetingLocation,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteRegistrationsBatch(
      List<int> registrationIds);
}

class RegistrationRemoteDataSourceImpl implements RegistrationRemoteDataSource {
  final ApiService apiService;

  RegistrationRemoteDataSourceImpl(this.apiService);

  @override
  Future<Either<Failure, List<RegistrationModel>>> getAllRegistrations({
    int page = 1,
    int limit = 10,
    String? status,
    int? roomId,
    String? nameStudent,
    String? meetingDatetime,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
        if (roomId != null) 'room_id': roomId.toString(),
        if (nameStudent != null) 'name_student': nameStudent,
        if (meetingDatetime != null) 'meeting_datetime': meetingDatetime,
      };

      final response = await apiService.get('/registrations', queryParams: queryParams);
      final registrations = (response['registrations'] as List)
          .map((json) => RegistrationModel.fromJson(json))
          .toList();
      return Right(registrations);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, RegistrationModel>> getRegistrationById(int id) async {
    try {
      final response = await apiService.get('/registrations/$id');
      final registration = RegistrationModel.fromJson(response);
      return Right(registration);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, RegistrationModel>> updateRegistrationStatus({
    required int id,
    required String status,
    String? rejectionReason,
  }) async {
    try {
      final body = {
        'status': status,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
      };
      final response = await apiService.put('/registrations/$id/status', body);
      final registration = RegistrationModel.fromJson(response['registration']);
      return Right(registration);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, RegistrationModel>> setMeetingDatetime({
    required int id,
    required DateTime meetingDatetime,
    String? meetingLocation,
  }) async {
    try {
      final body = {
        'meeting_datetime': meetingDatetime.toIso8601String(),
        if (meetingLocation != null) 'meeting_location': meetingLocation,
      };
      final response = await apiService.put('/registrations/$id/meeting', body);
      final registration = RegistrationModel.fromJson(response['registration']);
      return Right(registration);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteRegistrationsBatch(
      List<int> registrationIds) async {
    try {
      final body = {'registration_ids': registrationIds};
      print('Sending DELETE request to /registrations/batch with body: $body');
      final response = await apiService.delete('/registrations/batch', data: body);
      print('DELETE response: $response');

      // Xử lý deleted_ids an toàn
      List<int> deletedIds = [];
      if (response['deleted_ids'] != null) {
        final ids = List.from(response['deleted_ids']); // Chuyển JSArray sang List
        deletedIds = ids
            .map((id) => int.tryParse(id.toString())) // Parse an toàn, trả về null nếu lỗi
            .where((id) => id != null) // Lọc bỏ các giá trị null
            .cast<int>() // Chuyển thành List<int>
            .toList();
      }

      // Xử lý errors an toàn
      List<Map<String, dynamic>> errors = [];
      if (response['errors'] != null) {
        final errorList = List.from(response['errors']);
        errors = errorList
            .map((error) => error is Map<String, dynamic> ? error : <String, dynamic>{})
            .toList();
      }

      return Right({
        'deleted_ids': deletedIds,
        'errors': errors,
        'message': response['message'] as String?,
      });
    } catch (e) {
      print('Error in deleteRegistrationsBatch: $e');
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
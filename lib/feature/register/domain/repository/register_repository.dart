import 'package:dartz/dartz.dart';

import '../../../../src/core/error/failures.dart';
import '../../data/models/register_model.dart';
import '../entity/register_entity.dart';

abstract class RegistrationRepository {
  Future<Either<Failure, List<Registration>>> getAllRegistrations({
    int page,
    int limit,
    String? status,
    int? roomId,
    String? nameStudent,
    String? meetingDatetime,
  });

  Future<Either<Failure, Registration>> getRegistrationById(int id);

  Future<Either<Failure, Registration>> updateRegistrationStatus({
    required int id,
    required String status,
    String? rejectionReason,
  });

  Future<Either<Failure, Registration>> setMeetingDatetime({
    required int id,
    required DateTime meetingDatetime,
    String? meetingLocation,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteRegistrationsBatch(
      List<int> registrationIds);
}
import 'package:dartz/dartz.dart';
import '../entity/register_entity.dart';
import '../repository/register_repository.dart';
import '../../../../src/core/error/failures.dart';

class GetAllRegistrations {
  final RegistrationRepository repository;

  GetAllRegistrations(this.repository);

  Future<Either<Failure, (List<Registration>, int)>> call({
    int page = 1,
    int limit = 10,
    String? status,
    int? roomId,
    String? nameStudent,
    String? meetingDatetime,
  }) async {
    return await repository.getAllRegistrations(
      page: page,
      limit: limit,
      status: status,
      roomId: roomId,
      nameStudent: nameStudent,
      meetingDatetime: meetingDatetime,
    );
  }
}

class GetRegistrationById {
  final RegistrationRepository repository;

  GetRegistrationById(this.repository);

  Future<Either<Failure, Registration>> call(int id) async {
    return await repository.getRegistrationById(id);
  }
}

class UpdateRegistrationStatus {
  final RegistrationRepository repository;

  UpdateRegistrationStatus(this.repository);

  Future<Either<Failure, Registration>> call({
    required int id,
    required String status,
    String? rejectionReason,
  }) async {
    return await repository.updateRegistrationStatus(
      id: id,
      status: status,
      rejectionReason: rejectionReason,
    );
  }
}

class SetMeetingDatetime {
  final RegistrationRepository repository;

  SetMeetingDatetime(this.repository);

  Future<Either<Failure, Registration>> call({
    required int id,
    required DateTime meetingDatetime,
    String? meetingLocation,
  }) async {
    return await repository.setMeetingDatetime(
      id: id,
      meetingDatetime: meetingDatetime,
      meetingLocation: meetingLocation,
    );
  }
}

class DeleteRegistrationsBatch {
  final RegistrationRepository repository;

  DeleteRegistrationsBatch(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
      List<int> registrationIds) async {
    return await repository.deleteRegistrationsBatch(registrationIds);
  }
}
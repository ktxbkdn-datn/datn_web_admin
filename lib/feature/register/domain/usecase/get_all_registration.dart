import 'package:dartz/dartz.dart';

import '../../../../src/core/error/failures.dart';
import '../../data/models/register_model.dart';
import '../entity/register_entity.dart';
import '../repository/register_repository.dart';


class GetAllRegistrations {
  final RegistrationRepository repository;

  GetAllRegistrations(this.repository);

  Future<Either<Failure, List<Registration>>> call({
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
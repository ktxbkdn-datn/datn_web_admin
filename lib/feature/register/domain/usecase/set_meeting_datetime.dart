import 'package:dartz/dartz.dart';

import '../../../../src/core/error/failures.dart';
import '../../data/models/register_model.dart';
import '../entity/register_entity.dart';
import '../repository/register_repository.dart';

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
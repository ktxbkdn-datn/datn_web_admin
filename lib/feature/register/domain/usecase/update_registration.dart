import 'package:dartz/dartz.dart';

import '../../../../src/core/error/failures.dart';

import '../entity/register_entity.dart';
import '../repository/register_repository.dart';


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
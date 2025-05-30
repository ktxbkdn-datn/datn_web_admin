import 'package:dartz/dartz.dart';

import '../../../../src/core/error/failures.dart';
import '../repository/register_repository.dart';

class DeleteRegistrationsBatch {
  final RegistrationRepository repository;

  DeleteRegistrationsBatch(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
      List<int> registrationIds) async {
    return await repository.deleteRegistrationsBatch(registrationIds);
  }
}
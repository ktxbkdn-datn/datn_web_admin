import 'package:dartz/dartz.dart';

import '../../../../src/core/error/failures.dart';

import '../entity/register_entity.dart';
import '../repository/register_repository.dart';

class GetRegistrationById {
  final RegistrationRepository repository;

  GetRegistrationById(this.repository);

  Future<Either<Failure, Registration>> call(int id) async {
    return await repository.getRegistrationById(id);
  }
}
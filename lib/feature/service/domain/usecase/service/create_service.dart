import 'package:dartz/dartz.dart';

import '../../../../../src/core/error/failures.dart';
import '../../entities/service_entity.dart';
import '../../repository/service_repository.dart';

class CreateService {
  final ServiceRepository repository;

  CreateService({required this.repository});

  Future<Either<Failure, Service>> call(Service service) async {
    return await repository.createService(service);
  }
}
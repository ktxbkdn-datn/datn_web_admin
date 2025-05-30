import 'package:dartz/dartz.dart';

import '../../../../../src/core/error/failures.dart';
import '../../entities/service_entity.dart';
import '../../repository/service_repository.dart';

class UpdateService {
  final ServiceRepository repository;

  UpdateService({required this.repository});

  Future<Either<Failure, Service>> call(int serviceId, Service service) async {
    return await repository.updateService(serviceId, service);
  }
}
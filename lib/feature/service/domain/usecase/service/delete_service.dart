import 'package:dartz/dartz.dart';

import '../../../../../src/core/error/failures.dart';
import '../../entities/service_entity.dart';
import '../../repository/service_repository.dart';

class DeleteService {
  final ServiceRepository repository;

  DeleteService({required this.repository});

  Future<Either<Failure, void>> call(int serviceId) async {
    return await repository.deleteService(serviceId);
  }
}
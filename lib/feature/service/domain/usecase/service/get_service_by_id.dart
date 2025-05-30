import 'package:dartz/dartz.dart';

import '../../../../../src/core/error/failures.dart';
import '../../entities/service_entity.dart';
import '../../repository/service_repository.dart';
class GetServiceById {
  final ServiceRepository repository;

  GetServiceById({required this.repository});

  Future<Either<Failure, Service>> call(int serviceId) async {
    return await repository.getServiceById(serviceId);
  }
}
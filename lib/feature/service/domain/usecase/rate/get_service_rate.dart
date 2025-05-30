
import 'package:dartz/dartz.dart';

import '../../../../../src/core/error/failures.dart';
import '../../entities/service_rate_entity.dart';
import '../../repository/service_repository.dart';

class GetServiceRates {
  final ServiceRepository repository;

  GetServiceRates({required this.repository});

  Future<Either<Failure, List<ServiceRate>>> call({int? serviceId, int page = 1, int limit = 10}) async {
    return await repository.getServiceRates(serviceId: serviceId, page: page, limit: limit);
  }
}
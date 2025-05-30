import 'package:dartz/dartz.dart';

import '../../../../../src/core/error/failures.dart';
import '../../entities/service_rate_entity.dart';
import '../../repository/service_repository.dart';


class GetCurrentServiceRate {
  final ServiceRepository repository;

  GetCurrentServiceRate({required this.repository});

  Future<Either<Failure, ServiceRate>> call(int serviceId) async {
    return await repository.getCurrentServiceRate(serviceId);
  }
}
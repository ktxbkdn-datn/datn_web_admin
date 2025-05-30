import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';
import '../../entities/service_rate_entity.dart';
import '../../repository/service_repository.dart';


class CreateServiceRate {
  final ServiceRepository repository;

  CreateServiceRate({required this.repository});

  Future<Either<Failure, ServiceRate>> call(ServiceRate rate) async {
    return await repository.createServiceRate(rate);
  }
}
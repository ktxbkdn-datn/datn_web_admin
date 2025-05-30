import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';

import '../entities/service_entity.dart';
import '../entities/service_rate_entity.dart';


abstract class ServiceRepository {
  Future<Either<Failure, List<Service>>> getAllServices({int page = 1, int limit = 10});
  Future<Either<Failure, Service>> getServiceById(int serviceId);
  Future<Either<Failure, Service>> createService(Service service);
  Future<Either<Failure, Service>> updateService(int serviceId, Service service);
  Future<Either<Failure, void>> deleteService(int serviceId);
  Future<Either<Failure, List<ServiceRate>>> getServiceRates({int? serviceId, int page = 1, int limit = 10});
  Future<Either<Failure, ServiceRate>> getCurrentServiceRate(int serviceId);
  Future<Either<Failure, ServiceRate>> createServiceRate(ServiceRate rate);
  Future<Either<Failure, void>> deleteServiceRate(int rateId);
}
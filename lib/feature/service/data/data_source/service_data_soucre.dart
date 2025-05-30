import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';

import 'package:datn_web_admin/feature/service/data/models/service_model.dart';
import 'package:datn_web_admin/feature/service/data/models/service_rate_model.dart';

import '../../../../src/core/network/api_client.dart';

abstract class ServiceRemoteDataSource {
  Future<Either<Failure, List<ServiceModel>>> getAllServices({int page = 1, int limit = 10});
  Future<Either<Failure, ServiceModel>> getServiceById(int serviceId);
  Future<Either<Failure, ServiceModel>> createService(ServiceModel service);
  Future<Either<Failure, ServiceModel>> updateService(int serviceId, ServiceModel service);
  Future<Either<Failure, void>> deleteService(int serviceId);
  Future<Either<Failure, List<ServiceRateModel>>> getServiceRates({int? serviceId, int page = 1, int limit = 10});
  Future<Either<Failure, ServiceRateModel>> getCurrentServiceRate(int serviceId);
  Future<Either<Failure, ServiceRateModel>> createServiceRate(ServiceRateModel rate);
  Future<Either<Failure, void>> deleteServiceRate(int rateId);
}

class ServiceRemoteDataSourceImpl implements ServiceRemoteDataSource {
  final ApiService apiService;

  ServiceRemoteDataSourceImpl(this.apiService);

  @override
  Future<Either<Failure, List<ServiceModel>>> getAllServices({int page = 1, int limit = 10}) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      final response = await apiService.get('/services', queryParams: queryParams);
      final services = (response['services'] as List)
          .map((json) => ServiceModel.fromJson(json))
          .toList();
      return Right(services);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, ServiceModel>> getServiceById(int serviceId) async {
    try {
      final response = await apiService.get('/services/$serviceId');
      final service = ServiceModel.fromJson(response);
      return Right(service);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, ServiceModel>> createService(ServiceModel service) async {
    try {
      final response = await apiService.post('/services', service.toJson());
      final createdService = ServiceModel.fromJson(response);
      return Right(createdService);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, ServiceModel>> updateService(int serviceId, ServiceModel service) async {
    try {
      final response = await apiService.put('/services/$serviceId', service.toJson());
      final updatedService = ServiceModel.fromJson(response);
      return Right(updatedService);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteService(int serviceId) async {
    try {
      await apiService.delete('/services/$serviceId');
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<ServiceRateModel>>> getServiceRates({int? serviceId, int page = 1, int limit = 10}) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (serviceId != null) 'service_id': serviceId.toString(),
      };
      final response = await apiService.get('/service-rates', queryParams: queryParams);
      final serviceRates = (response['service_rates'] as List)
          .map((json) => ServiceRateModel.fromJson(json))
          .toList();
      return Right(serviceRates);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, ServiceRateModel>> getCurrentServiceRate(int serviceId) async {
    try {
      final response = await apiService.get('/service-rates/current/$serviceId');
      final serviceRate = ServiceRateModel.fromJson(response);
      return Right(serviceRate);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, ServiceRateModel>> createServiceRate(ServiceRateModel rate) async {
    try {
      final response = await apiService.post('/service-rates', rate.toJson());
      final createdRate = ServiceRateModel.fromJson(response);
      return Right(createdRate);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteServiceRate(int rateId) async {
    try {
      await apiService.delete('/service-rates/$rateId');
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Failure _handleError(dynamic error) {
    if (error is ServerFailure) {
      return ServerFailure(error.message);
    } else if (error is NetworkFailure) {
      return NetworkFailure(error.message);
    } else {
      return ServerFailure('Lỗi không xác định: $error');
    }
  }
}
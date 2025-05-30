import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';
import 'package:datn_web_admin/feature/service/domain/entities/service_entity.dart';
import 'package:datn_web_admin/feature/service/domain/entities/service_rate_entity.dart';
import 'package:datn_web_admin/feature/service/domain/repository/service_repository.dart';
import 'package:datn_web_admin/feature/service/data/data_source/service_data_soucre.dart';
import 'package:datn_web_admin/feature/service/data/models/service_model.dart';
import 'package:datn_web_admin/feature/service/data/models/service_rate_model.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceRemoteDataSource remoteDataSource;

  ServiceRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Service>>> getAllServices({int page = 1, int limit = 10}) async {
    try {
      final result = await remoteDataSource.getAllServices(page: page, limit: limit);
      return result.map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, Service>> getServiceById(int serviceId) async {
    try {
      final result = await remoteDataSource.getServiceById(serviceId);
      return result.map((model) => model.toEntity());
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, Service>> createService(Service service) async {
    try {
      final model = ServiceModel(
        serviceId: null, // API will assign ID
        name: service.name,
        unit: service.unit,
      );
      final result = await remoteDataSource.createService(model);
      return result.map((createdModel) => createdModel.toEntity());
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, Service>> updateService(int serviceId, Service service) async {
    try {
      final model = ServiceModel(
        serviceId: serviceId,
        name: service.name,
        unit: service.unit,
      );
      final result = await remoteDataSource.updateService(serviceId, model);
      return result.map((updatedModel) => updatedModel.toEntity());
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteService(int serviceId) async {
    try {
      final result = await remoteDataSource.deleteService(serviceId);
      return result;
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ServiceRate>>> getServiceRates(
      {int? serviceId, int page = 1, int limit = 10}) async {
    try {
      final result = await remoteDataSource.getServiceRates(serviceId: serviceId, page: page, limit: limit);
      return result.map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, ServiceRate>> getCurrentServiceRate(int serviceId) async {
    try {
      final result = await remoteDataSource.getCurrentServiceRate(serviceId);
      return result.map((model) => model.toEntity());
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, ServiceRate>> createServiceRate(ServiceRate rate) async {
    try {
      final model = ServiceRateModel(
        rateId: null, // API will assign ID
        unitPrice: rate.unitPrice,
        effectiveDate: rate.effectiveDate,
        serviceId: rate.serviceId,
      );
      final result = await remoteDataSource.createServiceRate(model);
      return result.map((createdModel) => createdModel.toEntity());
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteServiceRate(int rateId) async {
    try {
      final result = await remoteDataSource.deleteServiceRate(rateId);
      return result;
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }
}
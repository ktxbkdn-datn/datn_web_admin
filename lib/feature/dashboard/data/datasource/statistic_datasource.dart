// lib/src/features/statistics/datasource/statistic_datasource.dart
import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';
import 'package:datn_web_admin/src/core/network/api_client.dart';
import '../model/consumption_model.dart';

abstract class StatisticsRemoteDataSource {
  Future<Either<Failure, List<ConsumptionModel>>> getMonthlyConsumption({
    int? year,
    int? month,
    int? areaId, // Thêm areaId
  });
}

class StatisticsRemoteDataSourceImpl implements StatisticsRemoteDataSource {
  final ApiService apiService;

  StatisticsRemoteDataSourceImpl(this.apiService);

  @override
  Future<Either<Failure, List<ConsumptionModel>>> getMonthlyConsumption({
    int? year,
    int? month,
    int? areaId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (year != null) queryParams['year'] = year.toString();
      if (month != null) queryParams['month'] = month.toString();
      if (areaId != null) queryParams['area_id'] = areaId.toString(); // Thêm areaId vào query

      final response = await apiService.get(
        '/api/statistics/consumption',
        queryParams: queryParams,
      );
      final consumptionData = (response['data'] as List)
          .map((json) => ConsumptionModel.fromJson(json))
          .toList();
      return Right(consumptionData);
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
      return ServerFailure('Không thể kết nối tới server');
    }
  }
}
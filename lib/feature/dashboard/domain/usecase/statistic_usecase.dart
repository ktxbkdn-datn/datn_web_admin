// lib/src/features/statistics/usecase/statistic_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';
import '../entities/consumption.dart';
import '../repository/statistics_repository.dart';

class GetMonthlyConsumption {
  final StatisticsRepository repository;

  GetMonthlyConsumption(this.repository);

  Future<Either<Failure, List<Consumption>>> call({
    required int? year,
    int? month,
    int? areaId, // Thêm areaId
  }) async {
    return await repository.getMonthlyConsumption(
      year: year,
      month: month,
      areaId: areaId,
    );
  }
}
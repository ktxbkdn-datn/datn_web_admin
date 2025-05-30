// lib/src/features/statistics/repository/statistics_repository.dart
import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';
import '../entities/consumption.dart';

abstract class StatisticsRepository {
  Future<Either<Failure, List<Consumption>>> getMonthlyConsumption({
    required int? year,
    int? month,
    int? areaId, // Thêm areaId
  });
}
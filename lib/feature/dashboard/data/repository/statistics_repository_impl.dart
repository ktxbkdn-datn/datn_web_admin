// lib/src/features/statistics/repository/statistics_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';
import '../../domain/entities/consumption.dart';
import '../../domain/repository/statistics_repository.dart';
import '../datasource/statistic_datasource.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsRemoteDataSource remoteDataSource;

  StatisticsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Consumption>>> getMonthlyConsumption({
    required int? year,
    int? month,
    int? areaId,
  }) async {
    try {
      final result = await remoteDataSource.getMonthlyConsumption(
        year: year,
        month: month,
        areaId: areaId, // Truyền areaId
      );
      return result.map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      if (e is ServerFailure) {
        return Left(ServerFailure(e.message));
      } else if (e is NetworkFailure) {
        return Left(NetworkFailure(e.message));
      } else {
        return Left(ServerFailure('Không thể lấy dữ liệu thống kê tiêu thụ'));
      }
    }
  }
}
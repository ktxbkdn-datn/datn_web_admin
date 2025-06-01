import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';
import '../../domain/entities/consumption.dart';
import '../../domain/entities/room_status.dart';
import '../../domain/entities/room_capacity.dart';
import '../../domain/entities/contract_stats.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/entities/user_monthly_stats.dart';
import '../../domain/entities/occupancy_rate.dart';
import '../../domain/entities/report_stats.dart';
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
        areaId: areaId,
      );
      return result.map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<RoomStatus>>> getRoomStatusStats({
    int? year,
    int? month,
    int? quarter,
    int? areaId,
  }) async {
    try {
      final result = await remoteDataSource.getRoomStatusStats(
        year: year,
        month: month,
        quarter: quarter,
        areaId: areaId,
      );
      return result.map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<RoomCapacity>>> getRoomCapacityStats({
    int? year,
    int? month,
    int? quarter,
    int? areaId,
  }) async {
    try {
      final result = await remoteDataSource.getRoomCapacityStats(
        year: year,
        month: month,
        quarter: quarter,
        areaId: areaId,
      );
      return result.map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<ContractStats>>> getContractStats({
    int? year,
    int? month,
    int? quarter,
    int? areaId,
  }) async {
    try {
      final result = await remoteDataSource.getContractStats(
        year: year,
        month: month,
        quarter: quarter,
        areaId: areaId,
      );
      return result.map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<UserStats>>> getUserStats({
    int? areaId,
  }) async {
    try {
      final result = await remoteDataSource.getUserStats(
        areaId: areaId,
      );
      return result.map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<UserMonthlyStats>>> getUserMonthlyStats({
    int? year,
    int? month,
    int? quarter,
    int? areaId,
  }) async {
    try {
      final result = await remoteDataSource.getUserMonthlyStats(
        year: year,
        month: month,
        quarter: quarter,
        areaId: areaId,
      );
      return result.map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<OccupancyRate>>> getOccupancyRateStats({
    int? areaId,
  }) async {
    try {
      final result = await remoteDataSource.getOccupancyRateStats(
        areaId: areaId,
      );
      return result.map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, ReportStatsResponse>> getReportStats({
    int? year,
    int? month,
    int? areaId,
  }) async {
    try {
      final result = await remoteDataSource.getReportStats(
        year: year,
        month: month,
        areaId: areaId,
      );
      return result.map((response) => ReportStatsResponse(
        reportStats: response.reportStats.map((model) => model.toEntity()).toList(),
        trends: response.trends.map((model) => model.toEntity()).toList(),
      ));
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<RoomStatus>>> loadCachedRoomStats() async {
    try {
      final result = await remoteDataSource.loadRoomStats();
      return result.map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<UserMonthlyStats>>> loadCachedUserMonthlyStats() async {
    try {
      final result = await remoteDataSource.loadUserMonthlyStats();
      return result.map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<ReportStats>>> loadCachedReportStats() async {
    try {
      final result = await remoteDataSource.loadReportStats();
      return result.map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<UserStats>>> loadCachedUserStats() async {
    try {
      final result = await remoteDataSource.loadUserStats();
      return result.map((models) => models.map((model) => model.toEntity()).toList());
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
      return ServerFailure('Không thể lấy dữ liệu thống kê');
    }
  }
}
import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/feature/dashboard/data/model/consumption_model.dart';
import 'package:datn_web_admin/feature/dashboard/data/model/room_fill_rate_model.dart';
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
  Future<Either<Failure, void>> saveConsumption(List<Consumption> stats, int year, int? areaId) async {
    try {
      final models = stats.map((e) => ConsumptionModel(
        areaId: e.areaId,
        areaName: e.areaName,
        serviceUnits: e.serviceUnits,
        months: e.months,
      )).toList();
      final result = await remoteDataSource.saveConsumption(models, year, areaId);
      return result;
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<Consumption>>> loadCachedConsumption(int year, int? areaId) async {
    try {
      final result = await remoteDataSource.loadConsumption(year, areaId);
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
    int? roomId,
  }) async {
    try {
      final result = await remoteDataSource.getRoomStatusStats(
        year: year,
        month: month,
        quarter: quarter,
        areaId: areaId,
        roomId: roomId,
      );
      return result.map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getRoomStatusSummary({
    required int year,
    int? areaId,
  }) async {
    try {
      final result = await remoteDataSource.getRoomStatusSummary(
        year: year,
        areaId: areaId,
      );
      return result;
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserSummary({
    required int year,
    int? areaId,
  }) async {
    try {
      final result = await remoteDataSource.getUserSummary(
        year: year,
        areaId: areaId,
      );
      return result;
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> triggerManualSnapshot({
    required int year,
    int? month,
  }) async {
    try {
      final result = await remoteDataSource.triggerManualSnapshot(
        year: year,
        month: month,
      );
      return result;
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
    int? roomId,
  }) async {
    try {
      final result = await remoteDataSource.getUserMonthlyStats(
        year: year,
        month: month,
        quarter: quarter,
        areaId: areaId,
        roomId: roomId,
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
  Future<Either<Failure, List<RoomFillRate>>> getRoomFillRateStats({
    int? areaId,
    int? roomId,
  }) async {
    try {
      final result = await remoteDataSource.getRoomFillRateStats(
        areaId: areaId,
        roomId: roomId,
      );
      return result.map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> saveRoomFillRateStats(List<RoomFillRate> stats, int? areaId) async {
    try {
      final models = stats.map((e) => RoomFillRateModel(
        areaId: e.areaId,
        areaName: e.areaName,
        totalCapacity: e.totalCapacity,
        totalUsers: e.totalUsers,
        areaFillRate: e.areaFillRate,
        rooms: e.rooms.map((key, value) => MapEntry(key, RoomFillRateDetailModel(
          roomName: value.roomName,
          capacity: value.capacity,
          currentPersonNumber: value.currentPersonNumber,
          fillRate: value.fillRate,
        ))),
      )).toList();
      final result = await remoteDataSource.saveRoomFillRateStats(models, areaId);
      return result;
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<RoomFillRate>>> loadCachedRoomFillRateStats(int? areaId) async {
    try {
      final result = await remoteDataSource.loadRoomFillRateStats(areaId);
      return result.map((models) => models.map((model) => model.toEntity()).toList());
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
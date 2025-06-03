import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';
import '../entities/consumption.dart';
import '../entities/room_status.dart';
import '../entities/room_capacity.dart';
import '../entities/contract_stats.dart';
import '../entities/user_stats.dart';
import '../entities/user_monthly_stats.dart';
import '../entities/occupancy_rate.dart';
import '../entities/report_stats.dart';
import '../repository/statistics_repository.dart';

class GetMonthlyConsumption {
  final StatisticsRepository repository;

  GetMonthlyConsumption(this.repository);

  Future<Either<Failure, List<Consumption>>> call({
    required int year,
    int? month,
    int? areaId,
  }) async {
    return await repository.getMonthlyConsumption(
      year: year,
      month: month,
      areaId: areaId,
    );
  }
}

class SaveConsumption {
  final StatisticsRepository repository;

  SaveConsumption(this.repository);

  Future<Either<Failure, void>> call({
    required List<Consumption> stats,
    required int year,
    int? areaId,
  }) async {
    return await repository.saveConsumption(stats, year, areaId);
  }
}

class LoadCachedConsumption {
  final StatisticsRepository repository;

  LoadCachedConsumption(this.repository);

  Future<Either<Failure, List<Consumption>>> call({
    required int year,
    int? areaId,
  }) async {
    return await repository.loadCachedConsumption(year, areaId);
  }
}

class GetRoomStatusStats {
  final StatisticsRepository repository;

  GetRoomStatusStats(this.repository);

  Future<Either<Failure, List<RoomStatus>>> call({
    int? year,
    int? month,
    int? quarter,
    int? areaId,
    int? roomId,
  }) async {
    return await repository.getRoomStatusStats(
      year: year,
      month: month,
      quarter: quarter,
      areaId: areaId,
      roomId: roomId,
    );
  }
}

class GetRoomStatusSummary {
  final StatisticsRepository repository;

  GetRoomStatusSummary(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call({
    required int year,
    int? areaId,
  }) async {
    return await repository.getRoomStatusSummary(
      year: year,
      areaId: areaId,
    );
  }
}

class GetUserSummary {
  final StatisticsRepository repository;

  GetUserSummary(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call({
    required int year,
    int? areaId,
  }) async {
    return await repository.getUserSummary(
      year: year,
      areaId: areaId,
    );
  }
}

class TriggerManualSnapshot {
  final StatisticsRepository repository;

  TriggerManualSnapshot(this.repository);

  Future<Either<Failure, void>> call({
    required int year,
    int? month,
  }) async {
    return await repository.triggerManualSnapshot(
      year: year,
      month: month,
    );
  }
}

class GetRoomCapacityStats {
  final StatisticsRepository repository;

  GetRoomCapacityStats(this.repository);

  Future<Either<Failure, List<RoomCapacity>>> call({
    int? year,
    int? month,
    int? quarter,
    int? areaId,
  }) async {
    return await repository.getRoomCapacityStats(
      year: year,
      month: month,
      quarter: quarter,
      areaId: areaId,
    );
  }
}

class GetContractStats {
  final StatisticsRepository repository;

  GetContractStats(this.repository);

  Future<Either<Failure, List<ContractStats>>> call({
    int? year,
    int? month,
    int? quarter,
    int? areaId,
  }) async {
    return await repository.getContractStats(
      year: year,
      month: month,
      quarter: quarter,
      areaId: areaId,
    );
  }
}

class GetUserStats {
  final StatisticsRepository repository;

  GetUserStats(this.repository);

  Future<Either<Failure, List<UserStats>>> call({
    int? areaId,
  }) async {
    return await repository.getUserStats(
      areaId: areaId,
    );
  }
}

class GetUserMonthlyStats {
  final StatisticsRepository repository;

  GetUserMonthlyStats(this.repository);

  Future<Either<Failure, List<UserMonthlyStats>>> call({
    int? year,
    int? month,
    int? quarter,
    int? areaId,
    int? roomId,
  }) async {
    return await repository.getUserMonthlyStats(
      year: year,
      month: month,
      quarter: quarter,
      areaId: areaId,
      roomId: roomId,
    );
  }
}

class GetOccupancyRateStats {
  final StatisticsRepository repository;

  GetOccupancyRateStats(this.repository);

  Future<Either<Failure, List<OccupancyRate>>> call({
    int? areaId,
  }) async {
    return await repository.getOccupancyRateStats(
      areaId: areaId,
    );
  }
}

class GetReportStats {
  final StatisticsRepository repository;

  GetReportStats(this.repository);

  Future<Either<Failure, ReportStatsResponse>> call({
    int? year,
    int? month,
    int? areaId,
  }) async {
    return await repository.getReportStats(
      year: year,
      month: month,
      areaId: areaId,
    );
  }
}

class LoadCachedRoomStats {
  final StatisticsRepository repository;

  LoadCachedRoomStats(this.repository);

  Future<Either<Failure, List<RoomStatus>>> call() async {
    return await repository.loadCachedRoomStats();
  }
}

class LoadCachedUserMonthlyStats {
  final StatisticsRepository repository;

  LoadCachedUserMonthlyStats(this.repository);

  Future<Either<Failure, List<UserMonthlyStats>>> call() async {
    return await repository.loadCachedUserMonthlyStats();
  }
}

class LoadCachedReportStats {
  final StatisticsRepository repository;

  LoadCachedReportStats(this.repository);

  Future<Either<Failure, List<ReportStats>>> call() async {
    return await repository.loadCachedReportStats();
  }
}

class LoadCachedUserStats {
  final StatisticsRepository repository;

  LoadCachedUserStats(this.repository);

  Future<Either<Failure, List<UserStats>>> call() async {
    return await repository.loadCachedUserStats();
  }
}
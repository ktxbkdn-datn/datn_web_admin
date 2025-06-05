import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/feature/dashboard/data/model/room_fill_rate_model.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';
import '../entities/consumption.dart';
import '../entities/room_status.dart';
import '../entities/room_capacity.dart';
import '../entities/contract_stats.dart';
import '../entities/user_stats.dart';
import '../entities/user_monthly_stats.dart';
import '../entities/occupancy_rate.dart';
import '../entities/report_stats.dart';


abstract class StatisticsRepository {
  Future<Either<Failure, List<Consumption>>> getMonthlyConsumption({
    required int? year,
    int? month,
    int? areaId,
  });

  Future<Either<Failure, List<RoomStatus>>> getRoomStatusStats({
    int? year,
    int? month,
    int? quarter,
    int? areaId,
    int? roomId,
  });

  Future<Either<Failure, List<Map<String, dynamic>>>> getRoomStatusSummary({
    required int year,
    int? areaId,
  });

  Future<Either<Failure, List<Map<String, dynamic>>>> getUserSummary({
    required int year,
    int? areaId,
  });

  Future<Either<Failure, void>> triggerManualSnapshot({
    required int year,
    int? month,
  });

  Future<Either<Failure, List<RoomCapacity>>> getRoomCapacityStats({
    int? year,
    int? month,
    int? quarter,
    int? areaId,
  });

  Future<Either<Failure, List<ContractStats>>> getContractStats({
    int? year,
    int? month,
    int? quarter,
    int? areaId,
  });

  Future<Either<Failure, List<UserStats>>> getUserStats({
    int? areaId,
  });

  Future<Either<Failure, List<UserMonthlyStats>>> getUserMonthlyStats({
    int? year,
    int? month,
    int? quarter,
    int? areaId,
    int? roomId,
  });

  Future<Either<Failure, List<OccupancyRate>>> getOccupancyRateStats({
    int? areaId,
  });

  Future<Either<Failure, ReportStatsResponse>> getReportStats({
    int? year,
    int? month,
    int? areaId,
  });

  Future<Either<Failure, List<RoomFillRate>>> getRoomFillRateStats({
    int? areaId,
    int? roomId,
  });

  Future<Either<Failure, List<RoomStatus>>> loadCachedRoomStats();
  Future<Either<Failure, List<UserMonthlyStats>>> loadCachedUserMonthlyStats();
  Future<Either<Failure, List<ReportStats>>> loadCachedReportStats();
  Future<Either<Failure, List<UserStats>>> loadCachedUserStats();

  Future<Either<Failure, void>> saveConsumption(List<Consumption> stats, int year, int? areaId);
  Future<Either<Failure, List<Consumption>>> loadCachedConsumption(int year, int? areaId);

  Future<Either<Failure, void>> saveRoomFillRateStats(List<RoomFillRate> stats, int? areaId);
  Future<Either<Failure, List<RoomFillRate>>> loadCachedRoomFillRateStats(int? areaId);
}
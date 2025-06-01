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
  });

  Future<Either<Failure, List<OccupancyRate>>> getOccupancyRateStats({
    int? areaId,
  });

  Future<Either<Failure, ReportStatsResponse>> getReportStats({
    int? year,
    int? month,
    int? areaId,
  });

  Future<Either<Failure, List<RoomStatus>>> loadCachedRoomStats();
  Future<Either<Failure, List<UserMonthlyStats>>> loadCachedUserMonthlyStats();
  Future<Either<Failure, List<ReportStats>>> loadCachedReportStats();
  Future<Either<Failure, List<UserStats>>> loadCachedUserStats();
}
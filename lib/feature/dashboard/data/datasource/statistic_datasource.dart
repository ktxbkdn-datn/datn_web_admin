import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';
import 'package:datn_web_admin/src/core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/consumption_model.dart';
import '../model/room_status_model.dart';
import '../model/room_capacity_model.dart';
import '../model/contract_stats_model.dart';
import '../model/user_stats_model.dart';
import '../model/user_monthly_stats_model.dart';
import '../model/occupancy_rate_model.dart';
import '../model/report_stats_model.dart';
import '../../domain/entities/report_stats.dart';

abstract class StatisticsRemoteDataSource {
  Future<Either<Failure, List<ConsumptionModel>>> getMonthlyConsumption({
    int? year,
    int? month,
    int? areaId,
  });

  Future<Either<Failure, List<RoomStatusModel>>> getRoomStatusStats({
    int? year,
    int? month,
    int? quarter,
    int? areaId,
  });

  Future<Either<Failure, List<RoomCapacityModel>>> getRoomCapacityStats({
    int? year,
    int? month,
    int? quarter,
    int? areaId,
  });

  Future<Either<Failure, List<ContractStatsModel>>> getContractStats({
    int? year,
    int? month,
    int? quarter,
    int? areaId,
  });

  Future<Either<Failure, List<UserStatsModel>>> getUserStats({
    int? areaId,
  });

  Future<Either<Failure, List<UserMonthlyStatsModel>>> getUserMonthlyStats({
    int? year,
    int? month,
    int? quarter,
    int? areaId,
  });

  Future<Either<Failure, List<OccupancyRateModel>>> getOccupancyRateStats({
    int? areaId,
  });

  Future<Either<Failure, ReportStatsResponseModel>> getReportStats({
    int? year,
    int? month,
    int? areaId,
  });

  Future<Either<Failure, void>> saveRoomStats(List<RoomStatusModel> stats);
  Future<Either<Failure, List<RoomStatusModel>>> loadRoomStats();

  Future<Either<Failure, void>> saveUserMonthlyStats(List<UserMonthlyStatsModel> stats);
  Future<Either<Failure, List<UserMonthlyStatsModel>>> loadUserMonthlyStats();

  Future<Either<Failure, void>> saveReportStats(List<ReportStatsModel> stats);
  Future<Either<Failure, List<ReportStatsModel>>> loadReportStats();

  Future<Either<Failure, void>> saveUserStats(List<UserStatsModel> stats);
  Future<Either<Failure, List<UserStatsModel>>> loadUserStats();
}

class ReportStatsResponseModel {
  final List<ReportStatsModel> reportStats;
  final List<ReportTrendModel> trends;

  ReportStatsResponseModel({
    required this.reportStats,
    required this.trends,
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
      if (areaId != null) queryParams['area_id'] = areaId.toString();

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

  @override
  Future<Either<Failure, List<RoomStatusModel>>> getRoomStatusStats({
    int? year,
    int? month,
    int? quarter,
    int? areaId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (year != null) queryParams['year'] = year.toString();
      if (month != null) queryParams['month'] = month.toString();
      if (quarter != null) queryParams['quarter'] = quarter.toString();
      if (areaId != null) queryParams['area_id'] = areaId.toString();

      final response = await apiService.get(
        '/api/statistics/rooms/status',
        queryParams: queryParams,
      );
      final roomStatusData = (response['data'] as List)
          .map((json) => RoomStatusModel.fromJson(json))
          .toList();
      await saveRoomStats(roomStatusData);
      return Right(roomStatusData);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<RoomCapacityModel>>> getRoomCapacityStats({
    int? year,
    int? month,
    int? quarter,
    int? areaId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (year != null) queryParams['year'] = year.toString();
      if (month != null) queryParams['month'] = month.toString();
      if (quarter != null) queryParams['quarter'] = quarter.toString();
      if (areaId != null) queryParams['area_id'] = areaId.toString();

      final response = await apiService.get(
        '/api/statistics/rooms/capacity',
        queryParams: queryParams,
      );
      final roomCapacityData = (response['data'] as List)
          .map((json) => RoomCapacityModel.fromJson(json))
          .toList();
      return Right(roomCapacityData);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<ContractStatsModel>>> getContractStats({
    int? year,
    int? month,
    int? quarter,
    int? areaId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (year != null) queryParams['year'] = year.toString();
      if (month != null) queryParams['month'] = month.toString();
      if (quarter != null) queryParams['quarter'] = quarter.toString();
      if (areaId != null) queryParams['area_id'] = areaId.toString();

      final response = await apiService.get(
        '/api/statistics/contracts',
        queryParams: queryParams,
      );
      final contractStatsData = (response['data'] as List)
          .map((json) => ContractStatsModel.fromJson(json))
          .toList();
      return Right(contractStatsData);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<UserStatsModel>>> getUserStats({
    int? areaId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (areaId != null) queryParams['area_id'] = areaId.toString();

      final response = await apiService.get(
        '/api/statistics/users',
        queryParams: queryParams,
      );
      final userStatsData = (response['data'] as List)
          .map((json) => UserStatsModel.fromJson(json))
          .toList();
      await saveUserStats(userStatsData);
      return Right(userStatsData);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<UserMonthlyStatsModel>>> getUserMonthlyStats({
    int? year,
    int? month,
    int? quarter,
    int? areaId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (year != null) queryParams['year'] = year.toString();
      if (month != null) queryParams['month'] = month.toString();
      if (quarter != null) queryParams['quarter'] = quarter.toString();
      if (areaId != null) queryParams['area_id'] = areaId.toString();

      final response = await apiService.get(
        '/api/statistics/users/monthly',
        queryParams: queryParams,
      );
      final userMonthlyStatsData = (response['data'] as List)
          .map((json) => UserMonthlyStatsModel.fromJson(json))
          .toList();
      await saveUserMonthlyStats(userMonthlyStatsData);
      return Right(userMonthlyStatsData);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<OccupancyRateModel>>> getOccupancyRateStats({
    int? areaId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (areaId != null) queryParams['area_id'] = areaId.toString();

      final response = await apiService.get(
        '/api/statistics/rooms/occupancy-rate',
        queryParams: queryParams,
      );
      final occupancyRateData = (response['data'] as List)
          .map((json) => OccupancyRateModel.fromJson(json))
          .toList();
      return Right(occupancyRateData);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, ReportStatsResponseModel>> getReportStats({
    int? year,
    int? month,
    int? areaId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (year != null) queryParams['year'] = year.toString();
      if (month != null) queryParams['month'] = month.toString();
      if (areaId != null) queryParams['area_id'] = areaId.toString();

      final response = await apiService.get(
        '/api/statistics/reports',
        queryParams: queryParams,
      );
      final reportStatsData = (response['data'] as List)
          .map((json) => ReportStatsModel.fromJson(json))
          .toList();
      final trendData = (response['trends'] as List)
          .map((json) => ReportTrendModel.fromJson(json))
          .toList();
      await saveReportStats(reportStatsData);
      return Right(ReportStatsResponseModel(
        reportStats: reportStatsData,
        trends: trendData,
      ));
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> saveRoomStats(List<RoomStatusModel> stats) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String statsJson = jsonEncode(stats.map((stat) => {
        'areaId': stat.areaId,
        'areaName': stat.areaName,
        'statusCounts': stat.statusCounts,
      }).toList());
      await prefs.setString('room_stats', statsJson);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to save room stats: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<RoomStatusModel>>> loadRoomStats() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? statsJson = prefs.getString('room_stats');
      if (statsJson == null) {
        return Right([]);
      }
      List<dynamic> statsList = jsonDecode(statsJson);
      final stats = statsList.map((json) => RoomStatusModel(
        areaId: json['areaId'],
        areaName: json['areaName'],
        statusCounts: Map<String, int>.from(json['statusCounts']),
      )).toList();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure('Failed to load room stats: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveUserMonthlyStats(List<UserMonthlyStatsModel> stats) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String statsJson = jsonEncode(stats.map((stat) => {
        'areaId': stat.areaId,
        'areaName': stat.areaName,
        'months': stat.months,
      }).toList());
      await prefs.setString('user_stats', statsJson);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to save user stats: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<UserMonthlyStatsModel>>> loadUserMonthlyStats() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? statsJson = prefs.getString('user_stats');
      if (statsJson == null) {
        return Right([]);
      }
      List<dynamic> statsList = jsonDecode(statsJson);
      final stats = statsList.map((json) => UserMonthlyStatsModel(
        areaId: json['areaId'],
        areaName: json['areaName'],
        months: Map<int, int>.from(json['months']),
      )).toList();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure('Failed to load user stats: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveReportStats(List<ReportStatsModel> stats) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String statsJson = jsonEncode(stats.map((stat) => {
        'areaId': stat.areaId,
        'areaName': stat.areaName,
        'reportTypes': stat.reportTypes,
        'years': stat.years.map((year, yearStats) => MapEntry(
          year.toString(),
          {
            'total': yearStats.total,
            'months': yearStats.months,
            'types': yearStats.types,
          },
        )),
      }).toList());
      await prefs.setString('report_stats', statsJson);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to save report stats: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ReportStatsModel>>> loadReportStats() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? statsJson = prefs.getString('report_stats');
      if (statsJson == null) {
        return Right([]);
      }
      List<dynamic> statsList = jsonDecode(statsJson);
      final stats = statsList.map((json) {
        final years = (json['years'] as Map<String, dynamic>).map(
          (yearStr, yearData) {
            final year = int.parse(yearStr);
            final months = (yearData['months'] as Map<String, dynamic>).map(
              (monthStr, monthData) => MapEntry(
                int.parse(monthStr),
                Map<String, int>.from(monthData),
              ),
            );
            return MapEntry(
              year,
              ReportYearStats(
                total: yearData['total'],
                months: months,
                types: Map<String, int>.from(yearData['types']),
              ),
            );
          },
        );
        return ReportStatsModel(
          areaId: json['areaId'],
          areaName: json['areaName'],
          reportTypes: Map<String, String>.from(json['reportTypes']),
          years: years,
        );
      }).toList();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure('Failed to load report stats: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveUserStats(List<UserStatsModel> stats) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String statsJson = jsonEncode(stats.map((stat) => {
        'areaId': stat.areaId,
        'areaName': stat.areaName,
        'userCount': stat.userCount,
      }).toList());
      await prefs.setString('user_stats_total', statsJson);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to save user stats: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<UserStatsModel>>> loadUserStats() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? statsJson = prefs.getString('user_stats_total');
      if (statsJson == null) {
        return Right([]);
      }
      List<dynamic> statsList = jsonDecode(statsJson);
      final stats = statsList.map((json) => UserStatsModel(
        areaId: json['areaId'],
        areaName: json['areaName'],
        userCount: json['userCount'],
      )).toList();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure('Failed to load user stats: ${e.toString()}'));
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
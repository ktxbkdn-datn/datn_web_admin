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
import '../model/room_fill_rate_model.dart';
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
    int? roomId,
  });

  Future<Either<Failure, List<OccupancyRateModel>>> getOccupancyRateStats({
    int? areaId,
  });

  Future<Either<Failure, ReportStatsResponseModel>> getReportStats({
    int? year,
    int? month,
    int? areaId,
  });

  Future<Either<Failure, List<RoomFillRateModel>>> getRoomFillRateStats({
    int? areaId,
    int? roomId,
  });

  Future<Either<Failure, void>> saveRoomStats(List<RoomStatusModel> stats);
  Future<Either<Failure, List<RoomStatusModel>>> loadRoomStats();

  Future<Either<Failure, void>> saveUserMonthlyStats(List<UserMonthlyStatsModel> stats);
  Future<Either<Failure, List<UserMonthlyStatsModel>>> loadUserMonthlyStats();

  Future<Either<Failure, void>> saveReportStats(List<ReportStatsModel> stats);
  Future<Either<Failure, List<ReportStatsModel>>> loadReportStats();

  Future<Either<Failure, void>> saveUserStats(List<UserStatsModel> stats);
  Future<Either<Failure, List<UserStatsModel>>> loadUserStats();

  Future<Either<Failure, void>> saveConsumption(List<ConsumptionModel> stats, int year, int? areaId);
  Future<Either<Failure, List<ConsumptionModel>>> loadConsumption(int year, int? areaId);

  Future<Either<Failure, void>> saveRoomFillRateStats(List<RoomFillRateModel> stats, int? areaId);
  Future<Either<Failure, List<RoomFillRateModel>>> loadRoomFillRateStats(int? areaId);
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
      // Try loading from cache first
      final cacheResult = await loadConsumption(year ?? DateTime.now().year, areaId);
      if (cacheResult.isRight()) {
        final cachedData = cacheResult.getOrElse(() => []);
        if (cachedData.isNotEmpty) {
          print('StatisticsRemoteDataSource: Loaded cached consumption data for year $year, areaId $areaId'); // Debug log
          return Right(cachedData);
        }
      }

      // Fetch from API if no cache
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
      
      // Cache the fetched data
      await saveConsumption(consumptionData, year ?? DateTime.now().year, areaId);
      return Right(consumptionData);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> saveConsumption(List<ConsumptionModel> stats, int year, int? areaId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String statsJson = jsonEncode(stats.map((stat) => stat.toJson()).toList());
      String cacheKey = 'consumption_data_$year${areaId != null ? '_$areaId' : ''}';
      await prefs.setString(cacheKey, statsJson);
      print('StatisticsRemoteDataSource: Saved consumption data to cache with key $cacheKey'); // Debug log
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to save consumption stats: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ConsumptionModel>>> loadConsumption(int year, int? areaId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String cacheKey = 'consumption_data_$year${areaId != null ? '_$areaId' : ''}';
      String? statsJson = prefs.getString(cacheKey);
      if (statsJson == null) {
        return Right([]);
      }
      List<dynamic> statsList = jsonDecode(statsJson);
      final stats = statsList.map((json) => ConsumptionModel.fromJson(json)).toList();
      print('StatisticsRemoteDataSource: Loaded consumption data from cache with key $cacheKey'); // Debug log
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure('Failed to load consumption stats: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<RoomStatusModel>>> getRoomStatusStats({
    int? year,
    int? month,
    int? quarter,
    int? areaId,
    int? roomId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (year != null) queryParams['year'] = year.toString();
      if (month != null) queryParams['month'] = month.toString();
      if (quarter != null) queryParams['quarter'] = quarter.toString();
      if (areaId != null) queryParams['area_id'] = areaId.toString();
      if (roomId != null) queryParams['room_id'] = roomId.toString();

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
  Future<Either<Failure, List<Map<String, dynamic>>>> getRoomStatusSummary({
    required int year,
    int? areaId,
  }) async {
    try {
      final queryParams = <String, String>{'year': year.toString()};
      if (areaId != null) queryParams['area_id'] = areaId.toString();

      final response = await apiService.get(
        '/api/statistics/rooms/status/summary',
        queryParams: queryParams,
      );
      final summaryData = (response['data'] as List).cast<Map<String, dynamic>>();
      return Right(summaryData);
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
      final queryParams = <String, String>{'year': year.toString()};
      if (areaId != null) queryParams['area_id'] = areaId.toString();

      final response = await apiService.get(
        '/api/statistics/users/summary',
        queryParams: queryParams,
      );
      final summaryData = (response['data'] as List).cast<Map<String, dynamic>>();
      return Right(summaryData);
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
      final body = <String, dynamic>{'year': year};
      if (month != null) body['month'] = month;

      final response = await apiService.post(
        '/api/statistics/snapshot',
        body,
      );
      return Right(null);
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
    int? roomId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (year != null) queryParams['year'] = year.toString();
      if (month != null) queryParams['month'] = month.toString();
      if (quarter != null) queryParams['quarter'] = quarter.toString();
      if (areaId != null) queryParams['area_id'] = areaId.toString();
      if (roomId != null) queryParams['room_id'] = roomId.toString();

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
  Future<Either<Failure, List<RoomFillRateModel>>> getRoomFillRateStats({
    int? areaId,
    int? roomId,
  }) async {
    try {
      // Try loading from cache first
      final cacheResult = await loadRoomFillRateStats(areaId);
      if (cacheResult.isRight()) {
        final cachedData = cacheResult.getOrElse(() => []);
        if (cachedData.isNotEmpty) {
          print('StatisticsRemoteDataSource: Loaded cached fill rate data for areaId $areaId');
          return Right(cachedData);
        }
      }

      // Fetch from API if no cache
      final queryParams = <String, String>{};
      if (areaId != null) queryParams['area_id'] = areaId.toString();
      if (roomId != null) queryParams['room_id'] = roomId.toString();

      final response = await apiService.get(
        '/api/statistics/rooms/fill-rate',
        queryParams: queryParams,
      );
      final fillRateData = (response['data'] as List)
          .map((json) => RoomFillRateModel.fromJson(json))
          .toList();

      // Cache the fetched data
      await saveRoomFillRateStats(fillRateData, areaId);
      return Right(fillRateData);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> saveRoomStats(List<RoomStatusModel> stats) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String statsJson = jsonEncode(stats.map((stat) => stat.toJson()).toList());
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
      final stats = statsList.map((json) => RoomStatusModel.fromJson(json)).toList();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure('Failed to load room stats: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveUserMonthlyStats(List<UserMonthlyStatsModel> stats) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String statsJson = jsonEncode(stats.map((stat) => stat.toJson()).toList());
      await prefs.setString('user_monthly_stats', statsJson);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to save user monthly stats: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<UserMonthlyStatsModel>>> loadUserMonthlyStats() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? statsJson = prefs.getString('user_monthly_stats');
      if (statsJson == null) {
        return Right([]);
      }
      List<dynamic> statsList = jsonDecode(statsJson);
      final stats = statsList.map((json) => UserMonthlyStatsModel.fromJson(json)).toList();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure('Failed to load user monthly stats: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveReportStats(List<ReportStatsModel> stats) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String statsJson = jsonEncode(stats.map((stat) => stat.toJson()).toList());
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
      final stats = statsList.map((json) => ReportStatsModel.fromJson(json)).toList();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure('Failed to load report stats: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveUserStats(List<UserStatsModel> stats) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String statsJson = jsonEncode(stats.map((stat) => stat.toJson()).toList());
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
      final stats = statsList.map((json) => UserStatsModel.fromJson(json)).toList();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure('Failed to load user stats: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveRoomFillRateStats(List<RoomFillRateModel> stats, int? areaId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String statsJson = jsonEncode(stats.map((stat) => stat.toJson()).toList());
      String cacheKey = 'room_fill_rate_data${areaId != null ? '_$areaId' : ''}';
      await prefs.setString(cacheKey, statsJson);
      print('StatisticsRemoteDataSource: Saved fill rate data to cache with key $cacheKey');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to save room fill rate stats: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<RoomFillRateModel>>> loadRoomFillRateStats(int? areaId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String cacheKey = 'room_fill_rate_data${areaId != null ? '_$areaId' : ''}';
      String? statsJson = prefs.getString(cacheKey);
      if (statsJson == null) {
        return Right([]);
      }
      List<dynamic> statsList = jsonDecode(statsJson);
      final stats = statsList.map((json) => RoomFillRateModel.fromJson(json)).toList();
      print('StatisticsRemoteDataSource: Loaded fill rate data from cache with key $cacheKey');
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure('Failed to load room fill rate stats: ${e.toString()}'));
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
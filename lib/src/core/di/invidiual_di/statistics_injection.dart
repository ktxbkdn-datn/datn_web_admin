import 'package:datn_web_admin/feature/dashboard/data/datasource/statistic_datasource.dart';
import 'package:datn_web_admin/feature/dashboard/data/repository/statistics_repository_impl.dart';
import 'package:datn_web_admin/feature/dashboard/domain/repository/statistics_repository.dart';
import 'package:datn_web_admin/feature/dashboard/domain/usecase/statistic_usecase.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_bloc.dart';
import 'package:datn_web_admin/src/core/network/api_client.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void registerStatisticsDependencies() {
  // Đăng ký Data Source
  getIt.registerSingleton<StatisticsRemoteDataSource>(
    StatisticsRemoteDataSourceImpl(getIt<ApiService>()),
  );

  // Đăng ký Repository
  getIt.registerSingleton<StatisticsRepository>(
    StatisticsRepositoryImpl(getIt<StatisticsRemoteDataSource>()),
  );

  // Đăng ký Use Cases
  getIt.registerSingleton<GetMonthlyConsumption>(
    GetMonthlyConsumption(getIt<StatisticsRepository>()),
  );

  getIt.registerSingleton<GetRoomStatusStats>(
    GetRoomStatusStats(getIt<StatisticsRepository>()),
  );

  getIt.registerSingleton<GetRoomCapacityStats>(
    GetRoomCapacityStats(getIt<StatisticsRepository>()),
  );

  getIt.registerSingleton<GetContractStats>(
    GetContractStats(getIt<StatisticsRepository>()),
  );

  getIt.registerSingleton<GetUserStats>(
    GetUserStats(getIt<StatisticsRepository>()),
  );

  getIt.registerSingleton<GetUserMonthlyStats>(
    GetUserMonthlyStats(getIt<StatisticsRepository>()),
  );

  getIt.registerSingleton<GetOccupancyRateStats>(
    GetOccupancyRateStats(getIt<StatisticsRepository>()),
  );

  getIt.registerSingleton<GetReportStats>(
    GetReportStats(getIt<StatisticsRepository>()),
  );

  getIt.registerSingleton<LoadCachedRoomStats>(
    LoadCachedRoomStats(getIt<StatisticsRepository>()),
  );

  getIt.registerSingleton<LoadCachedUserMonthlyStats>(
    LoadCachedUserMonthlyStats(getIt<StatisticsRepository>()),
  );

  getIt.registerSingleton<LoadCachedReportStats>(
    LoadCachedReportStats(getIt<StatisticsRepository>()),
  );

  getIt.registerSingleton<LoadCachedUserStats>(
    LoadCachedUserStats(getIt<StatisticsRepository>()),
  );
  getIt.registerSingleton<GetRoomStatusSummary>(
    GetRoomStatusSummary(getIt<StatisticsRepository>()),
  );
  getIt.registerSingleton<GetUserSummary>(
    GetUserSummary(getIt<StatisticsRepository>()),
  );
  getIt.registerSingleton<TriggerManualSnapshot>(
    TriggerManualSnapshot(getIt<StatisticsRepository>()),
  );

  // Register SaveConsumption and LoadCachedConsumption use cases
  getIt.registerSingleton<SaveConsumption>(
    SaveConsumption(getIt<StatisticsRepository>()),
  );
  getIt.registerSingleton<LoadCachedConsumption>(
    LoadCachedConsumption(getIt<StatisticsRepository>()),
  );
  getIt.registerSingleton<GetRoomFillRateStats>(
    GetRoomFillRateStats(getIt<StatisticsRepository>()),
  );
  getIt.registerSingleton<SaveRoomFillRate>(
    SaveRoomFillRate(getIt<StatisticsRepository>()),
  );
  getIt.registerSingleton<LoadCachedRoomFillRate>(
    LoadCachedRoomFillRate(getIt<StatisticsRepository>()),
  );
  // Đăng ký Bloc
  getIt.registerFactory<StatisticsBloc>(
    () => StatisticsBloc(
      getMonthlyConsumption: getIt<GetMonthlyConsumption>(),
      getRoomStatusStats: getIt<GetRoomStatusStats>(),
      getRoomCapacityStats: getIt<GetRoomCapacityStats>(),
      getContractStats: getIt<GetContractStats>(),
      getUserStats: getIt<GetUserStats>(),
      getUserMonthlyStats: getIt<GetUserMonthlyStats>(),
      getOccupancyRateStats: getIt<GetOccupancyRateStats>(),
      getReportStats: getIt<GetReportStats>(),
      loadCachedRoomStats: getIt<LoadCachedRoomStats>(),
      loadCachedUserMonthlyStats: getIt<LoadCachedUserMonthlyStats>(),
      loadCachedReportStats: getIt<LoadCachedReportStats>(),
      loadCachedUserStats: getIt<LoadCachedUserStats>(),
      getRoomStatusSummary: GetRoomStatusSummary(getIt<StatisticsRepository>()), 
      getUserSummary: GetUserSummary(getIt<StatisticsRepository>()),
      triggerManualSnapshot: TriggerManualSnapshot(getIt<StatisticsRepository>()),
      saveConsumption: getIt<SaveConsumption>(),
      loadCachedConsumption: getIt<LoadCachedConsumption>(), 
      getRoomFillRateStats: getIt<GetRoomFillRateStats>(), 
      saveRoomFillRate: getIt<SaveRoomFillRate>(),
      loadCachedRoomFillRate: getIt<LoadCachedRoomFillRate>(),
      
    ),
  );
}
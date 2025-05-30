import 'package:get_it/get_it.dart';

import '../../../../feature/dashboard/data/datasource/statistic_datasource.dart';
import '../../../../feature/dashboard/data/repository/statistics_repository_impl.dart';
import '../../../../feature/dashboard/domain/repository/statistics_repository.dart';
import '../../../../feature/dashboard/domain/usecase/statistic_usecase.dart';
import '../../../../feature/dashboard/presentation/bloc/statistic_bloc.dart';
import '../../network/api_client.dart';


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

  // Đăng ký UseCase
  getIt.registerSingleton<GetMonthlyConsumption>(
    GetMonthlyConsumption(getIt<StatisticsRepository>()),
  );

  // Đăng ký Bloc
  getIt.registerFactory<StatisticsBloc>(
        () => StatisticsBloc(
      getMonthlyConsumption: getIt<GetMonthlyConsumption>(),
    ),
  );
}
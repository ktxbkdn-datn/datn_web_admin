import 'package:get_it/get_it.dart';

import '../../../../feature/service/data/data_source/service_data_soucre.dart';
import '../../../../feature/service/data/repository/service_reposiroty_impl.dart';
import '../../../../feature/service/domain/repository/service_repository.dart';
import '../../../../feature/service/domain/usecase/rate/create_service_rate.dart';
import '../../../../feature/service/domain/usecase/rate/delete_service_rate.dart';
import '../../../../feature/service/domain/usecase/rate/get_current_service_rate.dart';
import '../../../../feature/service/domain/usecase/rate/get_service_rate.dart';
import '../../../../feature/service/domain/usecase/service/create_service.dart';
import '../../../../feature/service/domain/usecase/service/delete_service.dart';
import '../../../../feature/service/domain/usecase/service/get_all_service.dart';
import '../../../../feature/service/domain/usecase/service/get_service_by_id.dart';
import '../../../../feature/service/domain/usecase/service/update_service.dart';
import '../../../../feature/service/presentation/bloc/service_bloc.dart';
import '../../network/api_client.dart';

final getIt = GetIt.instance;

void registerServicesDependencies() {
  // Đăng ký Data Source
  getIt.registerSingleton<ServiceRemoteDataSource>(ServiceRemoteDataSourceImpl(getIt<ApiService>()));

  // Đăng ký Repository
  getIt.registerSingleton<ServiceRepository>(
    ServiceRepositoryImpl(getIt<ServiceRemoteDataSource>()),
  );

  // Đăng ký UseCases
  getIt.registerSingleton<GetAllServices>(GetAllServices(repository: getIt<ServiceRepository>()));
  getIt.registerSingleton<GetServiceById>(GetServiceById(repository: getIt<ServiceRepository>()));
  getIt.registerSingleton<CreateService>(CreateService(repository: getIt<ServiceRepository>()));
  getIt.registerSingleton<UpdateService>(UpdateService(repository: getIt<ServiceRepository>()));
  getIt.registerSingleton<DeleteService>(DeleteService(repository: getIt<ServiceRepository>()));
  getIt.registerSingleton<GetServiceRates>(GetServiceRates(repository: getIt<ServiceRepository>()));
  getIt.registerSingleton<GetCurrentServiceRate>(GetCurrentServiceRate(repository: getIt<ServiceRepository>()));
  getIt.registerSingleton<CreateServiceRate>(CreateServiceRate(repository: getIt<ServiceRepository>()));
  getIt.registerSingleton<DeleteServiceRate>(DeleteServiceRate(repository: getIt<ServiceRepository>()));

  // Đăng ký Bloc
  getIt.registerFactory<ServiceBloc>(() => ServiceBloc(
    getAllServices: getIt<GetAllServices>(),
    getServiceById: getIt<GetServiceById>(),
    createService: getIt<CreateService>(),
    updateService: getIt<UpdateService>(),
    deleteService: getIt<DeleteService>(),
    getServiceRates: getIt<GetServiceRates>(),
    getCurrentServiceRate: getIt<GetCurrentServiceRate>(),
    createServiceRate: getIt<CreateServiceRate>(),
    deleteServiceRate: getIt<DeleteServiceRate>(),
  ));
}
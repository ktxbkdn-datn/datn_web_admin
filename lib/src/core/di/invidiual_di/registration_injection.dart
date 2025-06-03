import 'package:datn_web_admin/feature/register/domain/usecase/registration_usecase.dart';
import 'package:get_it/get_it.dart';

import '../../../../feature/register/data/data_resource/registration_datasource.dart';
import '../../../../feature/register/data/repository/registration_repository_impl.dart';
import '../../../../feature/register/domain/repository/register_repository.dart';

import '../../../../feature/register/presentation/bloc/registration_bloc.dart';
import '../../network/api_client.dart';

final getIt = GetIt.instance;

void registerRegistrationDependencies() {
  getIt.registerSingleton<RegistrationRemoteDataSource>(
    RegistrationRemoteDataSourceImpl(getIt<ApiService>()),
  );

  getIt.registerSingleton<RegistrationRepository>(
    RegistrationRepositoryImpl(getIt<RegistrationRemoteDataSource>()),
  );

  getIt.registerSingleton<GetAllRegistrations>(
    GetAllRegistrations(getIt<RegistrationRepository>()),
  );
  getIt.registerSingleton<GetRegistrationById>(
    GetRegistrationById(getIt<RegistrationRepository>()),
  );
  getIt.registerSingleton<UpdateRegistrationStatus>(
    UpdateRegistrationStatus(getIt<RegistrationRepository>()),
  );
  getIt.registerSingleton<SetMeetingDatetime>(
    SetMeetingDatetime(getIt<RegistrationRepository>()),
  );
  getIt.registerSingleton<DeleteRegistrationsBatch>(
    DeleteRegistrationsBatch(getIt<RegistrationRepository>()),
  );

  getIt.registerFactory<RegistrationBloc>(
        () => RegistrationBloc(
      getAllRegistrations: getIt<GetAllRegistrations>(),
      getRegistrationById: getIt<GetRegistrationById>(),
      updateRegistrationStatus: getIt<UpdateRegistrationStatus>(),
      setMeetingDatetime: getIt<SetMeetingDatetime>(),
      deleteRegistrationsBatch: getIt<DeleteRegistrationsBatch>(),
    ),
  );
}
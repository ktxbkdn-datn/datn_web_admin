import 'package:get_it/get_it.dart';

import '../../../../feature/admin/domain/usecase/get_admin_by_id.dart';
import '../../../../feature/auth/data/datasources/auth_datasource.dart';
import '../../../../feature/auth/data/repositories/auth_repository_impl.dart';
import '../../../../feature/auth/domain/repositories/auth_repository.dart';
import '../../../../feature/auth/domain/usecases/auth_usecase.dart';
import '../../../../feature/auth/presentation/bloc/auth_bloc.dart';
import '../../network/api_client.dart';

final getIt = GetIt.instance;

void registerAuthDependencies() {
  getIt.registerSingleton<AuthDataSource>(AuthDataSource(getIt<ApiService>()));
  getIt.registerSingleton<AuthRepository>(AuthRepositoryImpl(getIt<AuthDataSource>()));
  getIt.registerSingleton<Login>(Login(getIt<AuthRepository>()));
  getIt.registerSingleton<Logout>(Logout(getIt<AuthRepository>()));
  getIt.registerSingleton<ForgotPassword>(ForgotPassword(getIt<AuthRepository>()));
  getIt.registerSingleton<ResetPassword>(ResetPassword(getIt<AuthRepository>()));
  getIt.registerFactory<AuthBloc>(() => AuthBloc(
    login: getIt<Login>(),
    logout: getIt<Logout>(),
    forgotPassword: getIt<ForgotPassword>(),
    resetPassword: getIt<ResetPassword>(),
    getAdminById: getIt<GetAdminById>(),
    apiService: getIt<ApiService>(),
  ));
}
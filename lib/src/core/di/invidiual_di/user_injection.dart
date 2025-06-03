import 'package:datn_web_admin/feature/user/domain/usecases/user_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../../../feature/user/data/datasources/user_datasource.dart';
import '../../../../feature/user/data/repositories/user_repository_impl.dart';
import '../../../../feature/user/domain/repositories/user_repository.dart';

import '../../../../feature/user/presentation/bloc/user_bloc.dart';
import '../../network/api_client.dart';

final getIt = GetIt.instance;

void registerUserDependencies() {
  getIt.registerSingleton<http.Client>(http.Client());

  getIt.registerSingleton<UserDataSource>(UserDataSource(getIt<ApiService>()));
  getIt.registerSingleton<UserRepository>(UserRepositoryImpl(getIt<UserDataSource>()));
  getIt.registerSingleton<GetAllUsers>(GetAllUsers(getIt<UserRepository>()));
  getIt.registerSingleton<CreateUser>(CreateUser(getIt<UserRepository>()));
  getIt.registerSingleton<UpdateUser>(UpdateUser(getIt<UserRepository>()));
  getIt.registerSingleton<DeleteUser>(DeleteUser(getIt<UserRepository>()));
  getIt.registerFactory<UserBloc>(() => UserBloc(
    getAllUsers: getIt<GetAllUsers>(),
    createUser: getIt<CreateUser>(),
    updateUser: getIt<UpdateUser>(),
    deleteUser: getIt<DeleteUser>(),
  ));
}
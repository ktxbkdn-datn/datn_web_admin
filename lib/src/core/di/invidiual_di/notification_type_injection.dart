// lib/src/injection/notification_type_injection.dart
import 'package:get_it/get_it.dart';

import '../../../../feature/notification/data/datasource/noti_type_datasource.dart';
import '../../../../feature/notification/data/repository/noti_type_repository_impl.dart';
import '../../../../feature/notification/domain/repository/noti_type_repository.dart';
import '../../../../feature/notification/domain/usecase/notification_type_use_cases.dart';
import '../../../../feature/notification/presentation/bloc/noti_type/notification_type_bloc.dart';
import '../../network/api_client.dart';

final getIt = GetIt.instance;

void registerNotificationTypeDependencies() {
  getIt.registerSingleton<NotificationTypeRemoteDataSource>(
      NotificationTypeRemoteDataSourceImpl(getIt<ApiService>()));
  getIt.registerSingleton<NotificationTypeRepository>(
      NotificationTypeRepositoryImpl(getIt<NotificationTypeRemoteDataSource>()));
  getIt.registerSingleton<GetAllNotificationTypes>(
      GetAllNotificationTypes(getIt<NotificationTypeRepository>()));
  getIt.registerSingleton<CreateNotificationType>(
      CreateNotificationType(getIt<NotificationTypeRepository>()));
  getIt.registerSingleton<UpdateNotificationType>(
      UpdateNotificationType(getIt<NotificationTypeRepository>()));
  getIt.registerSingleton<DeleteNotificationType>(
      DeleteNotificationType(getIt<NotificationTypeRepository>()));
  getIt.registerFactory<NotificationTypeBloc>(() => NotificationTypeBloc(
    getAllNotificationTypes: getIt<GetAllNotificationTypes>(),
    createNotificationType: getIt<CreateNotificationType>(),
    updateNotificationType: getIt<UpdateNotificationType>(),
    deleteNotificationType: getIt<DeleteNotificationType>(),
  ));
}
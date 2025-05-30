// lib/src/injection/notification_injection.dart
import 'package:get_it/get_it.dart';

import '../../../../feature/notification/data/datasource/notification_datasource.dart';
import '../../../../feature/notification/data/repository/notification_repository_impl.dart';
import '../../../../feature/notification/domain/repository/notification_repository.dart';
import '../../../../feature/notification/domain/usecase/notification_usecase.dart';
import '../../../../feature/notification/presentation/bloc/noti/notification_bloc.dart';
import '../../network/api_client.dart';

final getIt = GetIt.instance;

void registerNotificationDependencies() {
  getIt.registerSingleton<NotificationRemoteDataSource>(
      NotificationRemoteDataSourceImpl(getIt<ApiService>()));
  getIt.registerSingleton<NotificationRepository>(
      NotificationRepositoryImpl(getIt<NotificationRemoteDataSource>()));
  getIt.registerSingleton<GetGeneralNotifications>(
      GetGeneralNotifications(getIt<NotificationRepository>()));
  getIt.registerSingleton<GetAllNotifications>(
      GetAllNotifications(getIt<NotificationRepository>()));
  getIt.registerSingleton<GetNotificationRecipients>(
      GetNotificationRecipients(getIt<NotificationRepository>()));
  getIt.registerSingleton<CreateNotification>(
      CreateNotification(getIt<NotificationRepository>()));
  getIt.registerSingleton<UpdateNotification>(
      UpdateNotification(getIt<NotificationRepository>()));
  getIt.registerSingleton<DeleteNotification>(
      DeleteNotification(getIt<NotificationRepository>()));
  getIt.registerSingleton<SearchNotifications>(
      SearchNotifications(getIt<NotificationRepository>()));
  getIt.registerFactory<NotificationBloc>(() => NotificationBloc(
    getGeneralNotifications: getIt<GetGeneralNotifications>(),
    getAllNotifications: getIt<GetAllNotifications>(),
    getNotificationRecipients: getIt<GetNotificationRecipients>(),
    createNotification: getIt<CreateNotification>(),
    updateNotification: getIt<UpdateNotification>(),
    deleteNotification: getIt<DeleteNotification>(),
    searchNotifications: getIt<SearchNotifications>(),
  ));
}
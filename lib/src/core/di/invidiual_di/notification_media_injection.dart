// lib/src/injection/notification_media_injection.dart
import 'package:get_it/get_it.dart';
import '../../../../feature/notification/data/datasource/notification_media_remote_data_source.dart';
import '../../../../feature/notification/data/repository/notification_media_repository_impl.dart';
import '../../../../feature/notification/domain/repository/notification_media_repository.dart';
import '../../../../feature/notification/domain/usecase/notification_media_use_cases.dart';
import '../../../../feature/notification/presentation/bloc/noti_media/notification_media_bloc.dart';
import '../../network/api_client.dart';

final getIt = GetIt.instance;

void registerNotificationMediaDependencies() {
  getIt.registerSingleton<NotificationMediaRemoteDataSource>(
      NotificationMediaRemoteDataSourceImpl(getIt<ApiService>()));
  getIt.registerSingleton<NotificationMediaRepository>(
      NotificationMediaRepositoryImpl(getIt<NotificationMediaRemoteDataSource>()));
  getIt.registerSingleton<GetNotificationMedia>(
      GetNotificationMedia(getIt<NotificationMediaRepository>()));
  getIt.registerSingleton<AddNotificationMedia>(
      AddNotificationMedia(getIt<NotificationMediaRepository>()));
  getIt.registerSingleton<UpdateNotificationMedia>(
      UpdateNotificationMedia(getIt<NotificationMediaRepository>()));
  getIt.registerSingleton<DeleteNotificationMedia>(
      DeleteNotificationMedia(getIt<NotificationMediaRepository>()));
  getIt.registerFactory<NotificationMediaBloc>(() => NotificationMediaBloc(
        getNotificationMedia: getIt<GetNotificationMedia>(),
        addNotificationMedia: getIt<AddNotificationMedia>(),
        updateNotificationMedia: getIt<UpdateNotificationMedia>(),
        deleteNotificationMedia: getIt<DeleteNotificationMedia>(),
      ));
}
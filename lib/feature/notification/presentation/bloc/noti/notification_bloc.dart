// notification_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import '../../../domain/entities/notification_entity.dart';

import '../../../domain/usecase/notification_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetGeneralNotifications getGeneralNotifications;
  final GetAllNotifications getAllNotifications;
  final GetNotificationRecipients getNotificationRecipients;
  final CreateNotification createNotification;
  final UpdateNotification updateNotification;
  final DeleteNotification deleteNotification;
  final SearchNotifications searchNotifications;

  NotificationBloc({
    required this.getGeneralNotifications,
    required this.getAllNotifications,
    required this.getNotificationRecipients,
    required this.createNotification,
    required this.updateNotification,
    required this.deleteNotification,
    required this.searchNotifications,
  }) : super(NotificationInitial()) {
    on<GetGeneralNotificationsEvent>(_onGetGeneralNotifications);
    on<GetAllNotificationsEvent>(_onGetAllNotifications);
    on<GetNotificationRecipientsEvent>(_onGetNotificationRecipients);
    on<CreateNotificationEvent>(_onCreateNotification);
    on<UpdateNotificationEvent>(_onUpdateNotification);
    on<DeleteNotificationEvent>(_onDeleteNotification);
    on<SearchNotificationsEvent>(_onSearchNotifications);
    on<ResetNotificationStateEvent>(_onResetNotificationState);
  }

  Future<void> _onGetGeneralNotifications(
      GetGeneralNotificationsEvent event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    final result = await getGeneralNotifications(page: event.page, limit: event.limit);
    result.fold(
          (failure) => emit(NotificationError(message: failure.message)),
          (notifications) => emit(NotificationsLoaded(notifications: notifications)),
    );
  }

  Future<void> _onGetAllNotifications(
      GetAllNotificationsEvent event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    final result = await getAllNotifications(
      page: event.page,
      limit: event.limit,
      targetType: event.targetType,
    );
    result.fold(
          (failure) => emit(NotificationError(message: failure.message)),
          (notifications) => emit(NotificationsLoaded(notifications: notifications)),
    );
  }

  Future<void> _onGetNotificationRecipients(
      GetNotificationRecipientsEvent event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    final result = await getNotificationRecipients(
      notificationId: event.notificationId,
      page: event.page,
      limit: event.limit,
      isRead: event.isRead,
    );
    result.fold(
          (failure) => emit(NotificationError(message: failure.message)),
          (recipients) => emit(NotificationRecipientsLoaded(recipients: recipients)),
    );
  }

  Future<void> _onCreateNotification(
      CreateNotificationEvent event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    final result = await createNotification(
      title: event.title,
      message: event.message,
      targetType: event.targetType,
      email: event.email,
      roomName: event.roomName,
      areaId: event.areaId,
      media: event.media,
      altTexts: event.altTexts,
    );
    result.fold(
          (failure) => emit(NotificationError(message: failure.message)),
          (notification) => emit(NotificationCreated(notification: notification)),
    );
  }

  Future<void> _onUpdateNotification(
      UpdateNotificationEvent event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    final result = await updateNotification(
      notificationId: event.notificationId,
      message: event.message,
      email: event.email,
      roomName: event.roomName,
      areaId: event.areaId,
      mediaIdsToDelete: event.mediaIdsToDelete,
      media: event.media,
      altTexts: event.altTexts,
    );
    result.fold(
          (failure) => emit(NotificationError(message: failure.message)),
          (notification) => emit(NotificationUpdated(notification: notification)),
    );
  }

  Future<void> _onDeleteNotification(
      DeleteNotificationEvent event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    final result = await deleteNotification(notificationId: event.notificationId);
    result.fold(
          (failure) => emit(NotificationError(message: failure.message)),
          (_) => emit(NotificationDeleted(notificationId: event.notificationId)),
    );
  }

  Future<void> _onSearchNotifications(
      SearchNotificationsEvent event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    final result = await searchNotifications(
      page: event.page,
      limit: event.limit,
      keyword: event.keyword,
      startDate: event.startDate,
      endDate: event.endDate,
    );
    result.fold(
          (failure) => emit(NotificationError(message: failure.message)),
          (notifications) => emit(NotificationsLoaded(notifications: notifications)),
    );
  }

  Future<void> _onResetNotificationState(
      ResetNotificationStateEvent event, Emitter<NotificationState> emit) async {
    emit(NotificationInitial());
  }
}
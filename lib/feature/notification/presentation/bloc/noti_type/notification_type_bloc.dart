// lib/src/features/notification_type/presentations/bloc/notification_type_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';

import '../../../domain/entities/notification_type_entity.dart';
import '../../../domain/usecase/notification_type_use_cases.dart';
import 'notification_type_event.dart';
import 'notification_type_state.dart';

class NotificationTypeBloc extends Bloc<NotificationTypeEvent, NotificationTypeState> {
  final GetAllNotificationTypes getAllNotificationTypes;
  final CreateNotificationType createNotificationType;
  final UpdateNotificationType updateNotificationType;
  final DeleteNotificationType deleteNotificationType;
  final Map<int, NotificationType> _typeCache = {};
  final List<NotificationType> _typeListCache = [];

  NotificationTypeBloc({
    required this.getAllNotificationTypes,
    required this.createNotificationType,
    required this.updateNotificationType,
    required this.deleteNotificationType,
  }) : super(NotificationTypeInitial()) {
    on<GetAllNotificationTypesEvent>(_onGetAllNotificationTypes);
    on<CreateNotificationTypeEvent>(_onCreateNotificationType);
    on<UpdateNotificationTypeEvent>(_onUpdateNotificationType);
    on<DeleteNotificationTypeEvent>(_onDeleteNotificationType);
    on<ResetNotificationTypeStateEvent>(_onResetNotificationTypeState);
  }

  Future<void> _onGetAllNotificationTypes(
      GetAllNotificationTypesEvent event, Emitter<NotificationTypeState> emit) async {
    emit(NotificationTypeLoading());
    final result = await getAllNotificationTypes(page: event.page, limit: event.limit);
    result.fold(
          (failure) {
        if (failure.message.contains('Page does not exist')) {
          _typeListCache.clear();
          emit(NotificationTypesLoaded(types: []));
        } else {
          emit(NotificationTypeError(message: failure.message));
        }
      },
          (types) {
        _typeListCache.clear();
        _typeListCache.addAll(types);
        emit(NotificationTypesLoaded(types: types));
      },
    );
  }

  Future<void> _onCreateNotificationType(
      CreateNotificationTypeEvent event, Emitter<NotificationTypeState> emit) async {
    emit(NotificationTypeLoading());
    final result = await createNotificationType(
      name: event.name,
      description: event.description,
      status: event.status,  // Truyền status
    );
    result.fold(
          (failure) => emit(NotificationTypeError(message: failure.message)),
          (type) {
        _typeCache[type.typeId ?? 0] = type;
        emit(NotificationTypeCreated(type: type));
        add(const GetAllNotificationTypesEvent());
      },
    );
  }

  Future<void> _onUpdateNotificationType(
      UpdateNotificationTypeEvent event, Emitter<NotificationTypeState> emit) async {
    emit(NotificationTypeLoading());
    final result = await updateNotificationType(
      typeId: event.typeId,
      name: event.name,
      description: event.description,
      status: event.status,  // Truyền status
    );
    result.fold(
          (failure) => emit(NotificationTypeError(message: failure.message)),
          (type) {
        _typeCache[event.typeId] = type;
        emit(NotificationTypeUpdated(type: type));
        add(const GetAllNotificationTypesEvent());
      },
    );
  }

  Future<void> _onDeleteNotificationType(
      DeleteNotificationTypeEvent event, Emitter<NotificationTypeState> emit) async {
    emit(NotificationTypeLoading());
    final result = await deleteNotificationType(typeId: event.typeId);
    result.fold(
          (failure) => emit(NotificationTypeError(message: failure.message)),
          (_) {
        _typeCache.remove(event.typeId);
        emit(NotificationTypeDeleted(typeId: event.typeId));
        add(const GetAllNotificationTypesEvent());
      },
    );
  }

  Future<void> _onResetNotificationTypeState(
      ResetNotificationTypeStateEvent event, Emitter<NotificationTypeState> emit) async {
    emit(NotificationTypeInitial());
    _typeCache.clear();
    _typeListCache.clear();
  }
}
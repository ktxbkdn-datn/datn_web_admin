// lib/src/features/notification/presentation/bloc/noti_media/notification_media_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../../domain/usecase/notification_media_use_cases.dart';
import 'notification_media_event.dart';
import 'notification_media_state.dart';

class NotificationMediaBloc extends Bloc<NotificationMediaEvent, NotificationMediaState> {
  final GetNotificationMedia getNotificationMedia;
  final AddNotificationMedia addNotificationMedia;
  final UpdateNotificationMedia updateNotificationMedia;
  final DeleteNotificationMedia deleteNotificationMedia;
  final Map<int, List<MediaInfo>> _mediaDataCache = {};

  NotificationMediaBloc({
    required this.getNotificationMedia,
    required this.addNotificationMedia,
    required this.updateNotificationMedia,
    required this.deleteNotificationMedia,
  }) : super(NotificationMediaInitial()) {
    on<GetNotificationMediaEvent>(_onGetNotificationMedia);
    on<AddNotificationMediaEvent>(_onAddNotificationMedia);
    on<UpdateNotificationMediaEvent>(_onUpdateNotificationMedia);
    on<DeleteNotificationMediaEvent>(_onDeleteNotificationMedia);
    on<ResetNotificationMediaStateEvent>(_onResetNotificationMediaState);
  }

  Future<void> _onGetNotificationMedia(
      GetNotificationMediaEvent event, Emitter<NotificationMediaState> emit) async {
    emit(NotificationMediaLoading(notificationId: event.notificationId));
    final result = await getNotificationMedia(
      notificationId: event.notificationId,
      page: event.page,
      limit: event.limit,
      fileType: event.fileType,
    );
    result.fold(
      (failure) {
        if (failure.message.contains('Không tìm thấy media cho thông báo') ||
            failure.message.contains('Notification not found')) {
          _mediaDataCache[event.notificationId] = [];
          emit(NotificationMediaLoaded(notificationId: event.notificationId, mediaItems: []));
        } else if (failure.message.contains('Unauthorized access')) {
          emit(NotificationMediaError(
            notificationId: event.notificationId,
            message: 'Bạn không có quyền truy cập media của thông báo này',
          ));
        } else if (failure.message.contains('Phương thức không được phép')) {
          emit(NotificationMediaError(
            notificationId: event.notificationId,
            message: 'Phương thức không được phép, vui lòng kiểm tra cấu hình server',
          ));
        } else {
          emit(NotificationMediaError(notificationId: event.notificationId, message: failure.message));
        }
      },
      (mediaList) {
        _mediaDataCache[event.notificationId] = mediaList; // mediaList is now List<MediaInfo>
        emit(NotificationMediaLoaded(
          notificationId: event.notificationId,
          mediaItems: mediaList,
        ));
      },
    );
  }

  Future<void> _onAddNotificationMedia(
      AddNotificationMediaEvent event, Emitter<NotificationMediaState> emit) async {
    emit(NotificationMediaLoading(notificationId: event.notificationId));
    final result = await addNotificationMedia(
      notificationId: event.notificationId,
      media: event.media,
      altTexts: event.altTexts,
    );
    result.fold(
      (failure) => emit(NotificationMediaError(notificationId: event.notificationId, message: failure.message)),
      (mediaList) {
        _mediaDataCache[event.notificationId] = mediaList;
        emit(NotificationMediaLoaded(
          notificationId: event.notificationId,
          mediaItems: mediaList,
        ));
      },
    );
  }

  Future<void> _onUpdateNotificationMedia(
      UpdateNotificationMediaEvent event, Emitter<NotificationMediaState> emit) async {
    emit(NotificationMediaLoading(notificationId: event.notificationId));
    final result = await updateNotificationMedia(
      notificationId: event.notificationId,
      mediaId: event.mediaId,
      altText: event.altText,
      isPrimary: event.isPrimary,
      sortOrder: event.sortOrder,
    );
    result.fold(
      (failure) => emit(NotificationMediaError(notificationId: event.notificationId, message: failure.message)),
      (media) {
        final updatedMediaList = (_mediaDataCache[event.notificationId] ?? []).map((m) {
          if (m.mediaId == media.mediaId) return media;
          return m;
        }).toList();
        _mediaDataCache[event.notificationId] = updatedMediaList;
        emit(NotificationMediaLoaded(
          notificationId: event.notificationId,
          mediaItems: updatedMediaList,
        ));
      },
    );
  }

  Future<void> _onDeleteNotificationMedia(
      DeleteNotificationMediaEvent event, Emitter<NotificationMediaState> emit) async {
    emit(NotificationMediaLoading(notificationId: event.notificationId));
    final result = await deleteNotificationMedia(mediaId: event.mediaId);
    result.fold(
      (failure) => emit(NotificationMediaError(notificationId: event.notificationId, message: failure.message)),
      (_) {
        _mediaDataCache.remove(event.notificationId);
        add(GetNotificationMediaEvent(notificationId: event.notificationId));
        emit(NotificationMediaDeleted());
      },
    );
  }

  Future<void> _onResetNotificationMediaState(
      ResetNotificationMediaStateEvent event, Emitter<NotificationMediaState> emit) async {
    emit(NotificationMediaInitial());
    _mediaDataCache.clear();
  }
}
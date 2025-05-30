// lib/src/features/notification_type/presentations/bloc/notification_type_event.dart
import 'package:equatable/equatable.dart';

abstract class NotificationTypeEvent extends Equatable {
  const NotificationTypeEvent();

  @override
  List<Object?> get props => [];
}

class GetAllNotificationTypesEvent extends NotificationTypeEvent {
  final int page;
  final int limit;

  const GetAllNotificationTypesEvent({
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [page, limit];
}

class CreateNotificationTypeEvent extends NotificationTypeEvent {
  final String name;
  final String? description;
  final String status;  // Thêm trường status

  const CreateNotificationTypeEvent({
    required this.name,
    this.description,
    required this.status,
  });

  @override
  List<Object?> get props => [name, description, status];
}

class UpdateNotificationTypeEvent extends NotificationTypeEvent {
  final int typeId;
  final String? name;
  final String? description;
  final String status;  // Thêm trường status

  const UpdateNotificationTypeEvent({
    required this.typeId,
    this.name,
    this.description,
    required this.status,
  });

  @override
  List<Object?> get props => [typeId, name, description, status];
}

class DeleteNotificationTypeEvent extends NotificationTypeEvent {
  final int typeId;

  const DeleteNotificationTypeEvent({required this.typeId});

  @override
  List<Object?> get props => [typeId];
}

class ResetNotificationTypeStateEvent extends NotificationTypeEvent {
  const ResetNotificationTypeStateEvent();

  @override
  List<Object?> get props => [];
}
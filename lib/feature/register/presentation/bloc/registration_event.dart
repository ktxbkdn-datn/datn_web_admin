import 'package:equatable/equatable.dart';

abstract class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object?> get props => [];
}

class FetchRegistrations extends RegistrationEvent {
  final int page;
  final int limit;
  final String? status;
  final int? roomId;
  final String? nameStudent;
  final String? meetingDatetime;

  const FetchRegistrations({
    this.page = 1,
    this.limit = 10,
    this.status,
    this.roomId,
    this.nameStudent,
    this.meetingDatetime,
  });

  @override
  List<Object?> get props => [page, limit, status, roomId, nameStudent, meetingDatetime];
}

class FetchRegistrationById extends RegistrationEvent {
  final int id;

  const FetchRegistrationById(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateRegistrationStatusEvent extends RegistrationEvent {
  final int id;
  final String status;
  final String? rejectionReason;

  const UpdateRegistrationStatusEvent({
    required this.id,
    required this.status,
    this.rejectionReason,
  });

  @override
  List<Object?> get props => [id, status, rejectionReason];
}

class SetMeetingDatetimeEvent extends RegistrationEvent {
  final int id;
  final DateTime meetingDatetime;
  final String? meetingLocation;

  const SetMeetingDatetimeEvent({
    required this.id,
    required this.meetingDatetime,
    this.meetingLocation,
  });

  @override
  List<Object?> get props => [id, meetingDatetime, meetingLocation];
}

class DeleteRegistrationsBatchEvent extends RegistrationEvent {
  final List<int> registrationIds;

  const DeleteRegistrationsBatchEvent(this.registrationIds);

  @override
  List<Object?> get props => [registrationIds];
}
// lib/src/features/dashboard/domain/entities/room_status.dart
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class RoomStatus extends Equatable {
  const RoomStatus({
    required this.areaId,
    required this.areaName,
    required this.rooms,
  });

  final int areaId;
  final String areaName;
  final Map<int, RoomDetail> rooms;

  RoomStatus toEntity() {
    return RoomStatus(
      areaId: areaId,
      areaName: areaName,
      rooms: Map<int, RoomDetail>.from(rooms),
    );
  }

  @override
  List<Object?> get props => [areaId, areaName, rooms];
}

@immutable
class RoomDetail extends Equatable {
  const RoomDetail({
    required this.roomName,
    required this.status,
    this.month,
  });

  final String roomName;
  final String status;
  final int? month;

  RoomDetail toEntity() {
    return RoomDetail(
      roomName: roomName,
      status: status,
      month: month,
    );
  }

  @override
  List<Object?> get props => [roomName, status, month];
}
// lib/src/features/dashboard/data/models/room_status_model.dart
import 'package:meta/meta.dart';
import '../../domain/entities/room_status.dart';

@immutable
class RoomStatusModel extends RoomStatus {
  const RoomStatusModel({
    required int areaId,
    required String areaName,
    required Map<int, RoomDetailModel> rooms,
  }) : super(areaId: areaId, areaName: areaName, rooms: rooms);

  factory RoomStatusModel.fromJson(Map<String, dynamic> json) {
    final roomsJson = json['rooms'] as Map<String, dynamic>? ?? {};
    final rooms = roomsJson.map(
      (key, value) => MapEntry(
        int.parse(key),
        RoomDetailModel.fromJson(value as Map<String, dynamic>),
      ),
    );

    return RoomStatusModel(
      areaId: json['area_id'] as int? ?? 0,
      areaName: json['area_name'] as String? ?? '',
      rooms: rooms,
    );
  }

  Map<String, dynamic> toJson() {
    final roomsJson = rooms.map(
      (key, value) => MapEntry(key.toString(), (value as RoomDetailModel).toJson()),
    );

    return {
      'area_id': areaId,
      'area_name': areaName,
      'rooms': roomsJson,
    };
  }

  @override
  RoomStatus toEntity() {
    return RoomStatus(
      areaId: areaId,
      areaName: areaName,
      rooms: rooms.map((key, value) => MapEntry(key, value.toEntity())),
    );
  }
}

@immutable
class RoomDetailModel extends RoomDetail {
  const RoomDetailModel({
    required String roomName,
    required String status,
    int? month,
  }) : super(roomName: roomName, status: status, month: month);

  factory RoomDetailModel.fromJson(Map<String, dynamic> json) {
    return RoomDetailModel(
      roomName: json['room_name'] as String? ?? '',
      status: json['status'] as String? ?? '',
      month: json['month'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_name': roomName,
      'status': status,
      'month': month,
    };
  }

  @override
  RoomDetail toEntity() {
    return RoomDetail(
      roomName: roomName,
      status: status,
      month: month,
    );
  }
}
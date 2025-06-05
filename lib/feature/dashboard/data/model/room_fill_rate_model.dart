import 'package:equatable/equatable.dart';

// Domain Layer Entity
class RoomFillRate extends Equatable {
  final int areaId;
  final String areaName;
  final int totalCapacity;
  final int totalUsers;
  final double areaFillRate;
  final Map<int, RoomFillRateDetail> rooms;

  const RoomFillRate({
    required this.areaId,
    required this.areaName,
    required this.totalCapacity,
    required this.totalUsers,
    required this.areaFillRate,
    required this.rooms,
  });

  @override
  List<Object?> get props => [areaId, areaName, totalCapacity, totalUsers, areaFillRate, rooms];
}

class RoomFillRateDetail extends Equatable {
  final String roomName;
  final int capacity;
  final int currentPersonNumber;
  final double fillRate;

  const RoomFillRateDetail({
    required this.roomName,
    required this.capacity,
    required this.currentPersonNumber,
    required this.fillRate,
  });

  @override
  List<Object?> get props => [roomName, capacity, currentPersonNumber, fillRate];
}

// Data Layer Model
class RoomFillRateModel {
  final int areaId;
  final String areaName;
  final int totalCapacity;
  final int totalUsers;
  final double areaFillRate;
  final Map<int, RoomFillRateDetailModel> rooms;

  RoomFillRateModel({
    required this.areaId,
    required this.areaName,
    required this.totalCapacity,
    required this.totalUsers,
    required this.areaFillRate,
    required this.rooms,
  });

  factory RoomFillRateModel.fromJson(Map<String, dynamic> json) {
    final roomsJson = json['rooms'] as Map<String, dynamic>? ?? {};
    final rooms = roomsJson.map(
      (key, value) => MapEntry(
        int.parse(key),
        RoomFillRateDetailModel.fromJson(value as Map<String, dynamic>),
      ),
    );

    return RoomFillRateModel(
      areaId: json['area_id'] as int,
      areaName: json['area_name'] as String,
      totalCapacity: json['total_capacity'] as int,
      totalUsers: json['total_users'] as int,
      areaFillRate: (json['area_fill_rate'] as num).toDouble(),
      rooms: rooms,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'area_id': areaId,
      'area_name': areaName,
      'total_capacity': totalCapacity,
      'total_users': totalUsers,
      'area_fill_rate': areaFillRate,
      'rooms': rooms.map((key, value) => MapEntry(key.toString(), value.toJson())),
    };
  }

  RoomFillRate toEntity() {
    return RoomFillRate(
      areaId: areaId,
      areaName: areaName,
      totalCapacity: totalCapacity,
      totalUsers: totalUsers,
      areaFillRate: areaFillRate,
      rooms: rooms.map((key, value) => MapEntry(key, value.toEntity())),
    );
  }
}

class RoomFillRateDetailModel {
  final String roomName;
  final int capacity;
  final int currentPersonNumber;
  final double fillRate;

  RoomFillRateDetailModel({
    required this.roomName,
    required this.capacity,
    required this.currentPersonNumber,
    required this.fillRate,
  });

  factory RoomFillRateDetailModel.fromJson(Map<String, dynamic> json) {
    return RoomFillRateDetailModel(
      roomName: json['room_name'] as String,
      capacity: json['capacity'] as int,
      currentPersonNumber: json['current_person_number'] as int,
      fillRate: (json['fill_rate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_name': roomName,
      'capacity': capacity,
      'current_person_number': currentPersonNumber,
      'fill_rate': fillRate,
    };
  }

  RoomFillRateDetail toEntity() {
    return RoomFillRateDetail(
      roomName: roomName,
      capacity: capacity,
      currentPersonNumber: currentPersonNumber,
      fillRate: fillRate,
    );
  }
}
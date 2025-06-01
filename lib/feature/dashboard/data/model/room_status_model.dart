import '../../domain/entities/room_status.dart';

class RoomStatusModel extends RoomStatus {
  const RoomStatusModel({
    required int areaId,
    required String areaName,
    required Map<String, int> statusCounts,
  }) : super(areaId: areaId, areaName: areaName, statusCounts: statusCounts);

  factory RoomStatusModel.fromJson(Map<String, dynamic> json) {
    final statusCountsJson = json['status_counts'] as Map<String, dynamic>;
    final statusCounts = statusCountsJson.map(
      (key, value) => MapEntry(key, value as int),
    );

    return RoomStatusModel(
      areaId: json['area_id'] as int,
      areaName: json['area_name'] as String,
      statusCounts: statusCounts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'area_id': areaId,
      'area_name': areaName,
      'status_counts': statusCounts,
    };
  }

  RoomStatus toEntity() {
    return RoomStatus(
      areaId: areaId,
      areaName: areaName,
      statusCounts: statusCounts,
    );
  }
}
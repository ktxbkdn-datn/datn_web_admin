import '../../domain/entities/room_capacity.dart';

class RoomCapacityModel extends RoomCapacity {
  const RoomCapacityModel({
    required int areaId,
    required String areaName,
    required Map<String, int> capacityCounts,
  }) : super(areaId: areaId, areaName: areaName, capacityCounts: capacityCounts);

  factory RoomCapacityModel.fromJson(Map<String, dynamic> json) {
    final capacityCountsJson = json['capacity_counts'] as Map<String, dynamic>;
    final capacityCounts = capacityCountsJson.map(
      (key, value) => MapEntry(key, value as int),
    );

    return RoomCapacityModel(
      areaId: json['area_id'] as int,
      areaName: json['area_name'] as String,
      capacityCounts: capacityCounts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'area_id': areaId,
      'area_name': areaName,
      'capacity_counts': capacityCounts,
    };
  }

  RoomCapacity toEntity() {
    return RoomCapacity(
      areaId: areaId,
      areaName: areaName,
      capacityCounts: capacityCounts,
    );
  }
}
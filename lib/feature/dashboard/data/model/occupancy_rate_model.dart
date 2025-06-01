import '../../domain/entities/occupancy_rate.dart';

class OccupancyRateModel extends OccupancyRate {
  const OccupancyRateModel({
    required int areaId,
    required String areaName,
    required int totalRooms,
    required int occupiedRooms,
    required double occupancyRate,
  }) : super(
          areaId: areaId,
          areaName: areaName,
          totalRooms: totalRooms,
          occupiedRooms: occupiedRooms,
          occupancyRate: occupancyRate,
        );

  factory OccupancyRateModel.fromJson(Map<String, dynamic> json) {
    return OccupancyRateModel(
      areaId: json['area_id'] as int,
      areaName: json['area_name'] as String,
      totalRooms: json['total_rooms'] as int,
      occupiedRooms: json['occupied_rooms'] as int,
      occupancyRate: (json['occupancy_rate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'area_id': areaId,
      'area_name': areaName,
      'total_rooms': totalRooms,
      'occupied_rooms': occupiedRooms,
      'occupancy_rate': occupancyRate,
    };
  }

  OccupancyRate toEntity() {
    return OccupancyRate(
      areaId: areaId,
      areaName: areaName,
      totalRooms: totalRooms,
      occupiedRooms: occupiedRooms,
      occupancyRate: occupancyRate,
    );
  }
}
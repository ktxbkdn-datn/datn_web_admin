class OccupancyRate {
  final int areaId;
  final String areaName;
  final int totalRooms;
  final int occupiedRooms;
  final double occupancyRate;

  const OccupancyRate({
    required this.areaId,
    required this.areaName,
    required this.totalRooms,
    required this.occupiedRooms,
    required this.occupancyRate,
  });
}
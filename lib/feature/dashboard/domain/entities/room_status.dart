class RoomStatus {
  final int areaId;
  final String areaName;
  final Map<String, int> statusCounts;

  const RoomStatus({
    required this.areaId,
    required this.areaName,
    required this.statusCounts,
  });
}
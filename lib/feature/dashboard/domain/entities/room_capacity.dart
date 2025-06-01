class RoomCapacity {
  final int areaId;
  final String areaName;
  final Map<String, int> capacityCounts;

  const RoomCapacity({
    required this.areaId,
    required this.areaName,
    required this.capacityCounts,
  });
}
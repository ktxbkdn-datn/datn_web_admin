class Consumption {
  final int areaId;
  final String areaName;
  final Map<String, String> serviceUnits;
  final Map<int, Map<String, double>> months;

  const Consumption({
    required this.areaId,
    required this.areaName,
    required this.serviceUnits,
    required this.months,
  });
}
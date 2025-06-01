class UserMonthlyStats {
  final int areaId;
  final String areaName;
  final Map<int, int> months;

  const UserMonthlyStats({
    required this.areaId,
    required this.areaName,
    required this.months,
  });
}
class ReportStats {
  final int areaId;
  final String areaName;
  final Map<String, String> reportTypes;
  final Map<int, ReportYearStats> years;

  const ReportStats({
    required this.areaId,
    required this.areaName,
    required this.reportTypes,
    required this.years,
  });
}

class ReportYearStats {
  final int total;
  final Map<int, Map<String, int>> months;
  final Map<String, int> types;

  const ReportYearStats({
    required this.total,
    required this.months,
    required this.types,
  });
}

class ReportTrend {
  final int areaId;
  final String areaName;
  final int year;
  final int totalReports;
  final int totalContracts;
  final double reportPerContract;

  const ReportTrend({
    required this.areaId,
    required this.areaName,
    required this.year,
    required this.totalReports,
    required this.totalContracts,
    required this.reportPerContract,
  });
}

class ReportStatsResponse {
  final List<ReportStats> reportStats;
  final List<ReportTrend> trends;

  const ReportStatsResponse({
    required this.reportStats,
    required this.trends,
  });
}
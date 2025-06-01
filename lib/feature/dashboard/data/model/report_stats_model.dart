import '../../domain/entities/report_stats.dart';

class ReportStatsModel extends ReportStats {
  const ReportStatsModel({
    required int areaId,
    required String areaName,
    required Map<String, String> reportTypes,
    required Map<int, ReportYearStats> years,
  }) : super(areaId: areaId, areaName: areaName, reportTypes: reportTypes, years: years);

  factory ReportStatsModel.fromJson(Map<String, dynamic> json) {
    final reportTypesJson = json['report_types'] as Map<String, dynamic>;
    final reportTypes = reportTypesJson.map(
      (key, value) => MapEntry(key, value as String),
    );

    final yearsJson = json['years'] as Map<String, dynamic>;
    final years = yearsJson.map(
      (yearStr, yearData) {
        final year = int.parse(yearStr);
        final monthsJson = yearData['months'] as Map<String, dynamic>;
        final months = monthsJson.map(
          (monthStr, monthData) {
            final month = int.parse(monthStr);
            final monthDataMap = (monthData as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, value as int),
            );
            return MapEntry(month, monthDataMap);
          },
        );
        final typesJson = yearData['types'] as Map<String, dynamic>;
        final types = typesJson.map(
          (key, value) => MapEntry(key, value as int),
        );

        return MapEntry(
          year,
          ReportYearStats(
            total: yearData['total'] as int,
            months: months,
            types: types,
          ),
        );
      },
    );

    return ReportStatsModel(
      areaId: json['area_id'] as int,
      areaName: json['area_name'] as String,
      reportTypes: reportTypes,
      years: years,
    );
  }

  Map<String, dynamic> toJson() {
    final yearsJson = years.map(
      (year, yearStats) {
        final monthsJson = yearStats.months.map(
          (month, monthData) => MapEntry(month.toString(), monthData),
        );
        return MapEntry(
          year.toString(),
          {
            'total': yearStats.total,
            'months': monthsJson,
            'types': yearStats.types,
          },
        );
      },
    );

    return {
      'area_id': areaId,
      'area_name': areaName,
      'report_types': reportTypes,
      'years': yearsJson,
    };
  }

  @override
  ReportStats toEntity() {
    return ReportStats(
      areaId: areaId,
      areaName: areaName,
      reportTypes: reportTypes,
      years: years,
    );
  }
}

class ReportTrendModel extends ReportTrend {
  const ReportTrendModel({
    required int areaId,
    required String areaName,
    required int year,
    required int totalReports,
    required int totalContracts,
    required double reportPerContract,
  }) : super(
          areaId: areaId,
          areaName: areaName,
          year: year,
          totalReports: totalReports,
          totalContracts: totalContracts,
          reportPerContract: reportPerContract,
        );

  factory ReportTrendModel.fromJson(Map<String, dynamic> json) {
    return ReportTrendModel(
      areaId: json['area_id'] as int,
      areaName: json['area_name'] as String,
      year: json['year'] as int,
      totalReports: json['total_reports'] as int,
      totalContracts: json['total_contracts'] as int,
      reportPerContract: (json['report_per_contract'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'area_id': areaId,
      'area_name': areaName,
      'year': year,
      'total_reports': totalReports,
      'total_contracts': totalContracts,
      'report_per_contract': reportPerContract,
    };
  }

  @override
  ReportTrend toEntity() {
      return ReportTrend(
        areaId: areaId,
        areaName: areaName,
        year: year,
        totalReports: totalReports,
        totalContracts: totalContracts,
        reportPerContract: reportPerContract,
      );
    }
}
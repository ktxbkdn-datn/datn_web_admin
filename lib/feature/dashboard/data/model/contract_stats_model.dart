import '../../domain/entities/contract_stats.dart';

class ContractStatsModel extends ContractStats {
  const ContractStatsModel({
    required int areaId,
    required String areaName,
    required Map<int, int> months,
  }) : super(areaId: areaId, areaName: areaName, months: months);

  factory ContractStatsModel.fromJson(Map<String, dynamic> json) {
    final monthsJson = json['months'] as Map<String, dynamic>;
    final months = monthsJson.map(
      (key, value) => MapEntry(int.parse(key), value as int),
    );

    return ContractStatsModel(
      areaId: json['area_id'] as int,
      areaName: json['area_name'] as String,
      months: months,
    );
  }

  Map<String, dynamic> toJson() {
    final monthsJson = months.map(
      (month, count) => MapEntry(month.toString(), count),
    );

    return {
      'area_id': areaId,
      'area_name': areaName,
      'months': monthsJson,
    };
  }

  ContractStats toEntity() {
    return ContractStats(
      areaId: areaId,
      areaName: areaName,
      months: months,
    );
  }
}
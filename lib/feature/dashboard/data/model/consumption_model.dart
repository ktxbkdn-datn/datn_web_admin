
import '../../domain/entities/consumption.dart';

class ConsumptionModel extends Consumption {
  const ConsumptionModel({
    required int areaId,
    required String areaName,
    required Map<String, String> serviceUnits,
    required Map<int, Map<String, double>> months,
  }) : super(areaId: areaId, areaName: areaName, serviceUnits: serviceUnits, months: months);

  factory ConsumptionModel.fromJson(Map<String, dynamic> json) {
    final monthsJson = json['months'] as Map<String, dynamic>;
    final months = <int, Map<String, double>>{};
    final serviceUnits = (json['service_units'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, value as String),
    ) ?? <String, String>{};

    monthsJson.forEach((monthStr, services) {
      final month = int.parse(monthStr);
      final serviceMap = (services as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
      );
      months[month] = serviceMap;
    });

    return ConsumptionModel(
      areaId: json['area_id'] as int,
      areaName: json['area_name'] as String,
      serviceUnits: serviceUnits,
      months: months,
    );
  }

  Map<String, dynamic> toJson() {
    final monthsJson = months.map(
          (month, services) => MapEntry(
        month.toString(),
        services.map((key, value) => MapEntry(key, value)),
      ),
    );

    return {
      'area_id': areaId,
      'area_name': areaName,
      'service_units': serviceUnits,
      'months': monthsJson,
    };
  }

  Consumption toEntity() {
    return Consumption(
      areaId: areaId,
      areaName: areaName,
      serviceUnits: serviceUnits,
      months: months,
    );
  }
}
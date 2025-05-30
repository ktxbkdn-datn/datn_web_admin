import 'package:equatable/equatable.dart';
import '../../domain/entities/service_entity.dart';

class ServiceModel extends Equatable {
  final int? serviceId;
  final String name;
  final String unit;

  const ServiceModel({
    required this.serviceId,
    required this.name,
    required this.unit,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    print('Parsing ServiceModel: $json'); // Log dữ liệu JSON
    try {
      print('Parsing serviceId: ${json['service_id']}');
      final serviceId = json['service_id'] as int?;
      print('Parsing name: ${json['name']}');
      final name = json['name'] as String? ?? '';
      print('Parsing unit: ${json['unit']}');
      final unit = json['unit'] as String? ?? '';

      return ServiceModel(
        serviceId: serviceId,
        name: name,
        unit: unit,
      );
    } catch (e) {
      print('Error parsing ServiceModel: $e'); // Log lỗi parse
      rethrow; // Ném lại lỗi để tầng trên có thể bắt được
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'name': name,
      'unit': unit,
    };
  }

  Service toEntity() {
    return Service(
      serviceId: serviceId ?? 0, // Giá trị mặc định nếu serviceId là null
      name: name,
      unit: unit,
    );
  }

  @override
  List<Object?> get props => [serviceId, name, unit];
}
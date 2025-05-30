import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/service_rate_entity.dart';

class ServiceRateModel extends Equatable {
  final int? rateId;
  final double unitPrice;
  final DateTime? effectiveDate;
  final int? serviceId;

  const ServiceRateModel({
    required this.rateId,
    required this.unitPrice,
    required this.effectiveDate,
    required this.serviceId,
  });

  factory ServiceRateModel.fromJson(Map<String, dynamic> json) {
    print('Parsing ServiceRateModel: $json'); // Log dữ liệu JSON
    try {
      print('Parsing rateId: ${json['rate_id']}');
      final rateId = json['rate_id'] as int?;
      print('Parsing unitPrice: ${json['unit_price']}');
      final unitPrice = double.tryParse(json['unit_price']?.toString() ?? '0.0') ?? 0.0;
      print('Parsing effectiveDate: ${json['effective_date']}');
      final effectiveDate = json['effective_date'] != null
          ? DateTime.tryParse(json['effective_date'] as String)
          : null;
      print('Parsing serviceId: ${json['service_id']}');
      final serviceId = json['service_id'] as int?;

      return ServiceRateModel(
        rateId: rateId,
        unitPrice: unitPrice,
        effectiveDate: effectiveDate,
        serviceId: serviceId,
      );
    } catch (e) {
      print('Error parsing ServiceRateModel: $e'); // Log lỗi parse
      rethrow; // Ném lại lỗi để tầng trên có thể bắt được
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'rate_id': rateId,
      'unit_price': unitPrice,
      'effective_date': DateFormat('yyyy-MM-dd').format(effectiveDate!), // Định dạng thành YYYY-MM-DD
      'service_id': serviceId,
    };
  }

  ServiceRate toEntity() {
    return ServiceRate(
      rateId: rateId ?? 0, // Giá trị mặc định nếu rateId là null
      unitPrice: unitPrice,
      effectiveDate: effectiveDate ?? DateTime.now(), // Giá trị mặc định nếu effectiveDate là null
      serviceId: serviceId ?? 0, // Giá trị mặc định nếu serviceId là null
    );
  }

  @override
  List<Object?> get props => [rateId, unitPrice, effectiveDate, serviceId];
}
import 'package:equatable/equatable.dart';

class ServiceRate extends Equatable {
  final int? rateId;
  final double unitPrice;
  final DateTime effectiveDate;
  final int serviceId;

  const ServiceRate({
    required this.rateId,
    required this.unitPrice,
    required this.effectiveDate,
    required this.serviceId,
  });

  @override
  List<Object?> get props => [rateId, unitPrice, effectiveDate, serviceId];
}
import 'package:equatable/equatable.dart';
import '../../domain/entities/bill_detail_entity.dart';

class BillDetailModel extends Equatable {
  final int? detailId;
  final int? rateId;
  final double previousReading;
  final double currentReading;
  final double price;
  final int? roomId;
  final String? roomName; // Added roomName field
  final DateTime billMonth;
  final int? submittedBy;
  final DateTime? submittedAt;
  final RateDetailsModel? rateDetails;
  final SubmitterDetailsModel? submitterDetails;
  final int? monthlyBillId;
  final bool? submitted;
  final String? paymentStatus;

  const BillDetailModel({
    this.detailId,
    this.rateId,
    required this.previousReading,
    required this.currentReading,
    required this.price,
    this.roomId,
    this.roomName, // Added to constructor
    required this.billMonth,
    this.submittedBy,
    this.submittedAt,
    this.rateDetails,
    this.submitterDetails,
    this.monthlyBillId,
    this.submitted,
    this.paymentStatus,
  });

  factory BillDetailModel.fromJson(Map<String, dynamic> json) {
    return BillDetailModel(
      detailId: json['detail_id'] as int?, // Có thể null
      rateId: json['rate_id'] as int?,     // Có thể null
      previousReading: json['previous_reading'] != null
          ? double.tryParse(json['previous_reading'].toString()) ?? 0.0
          : 0.0,
      currentReading: json['current_reading'] != null
          ? double.tryParse(json['current_reading'].toString()) ?? 0.0
          : 0.0,
      price: json['price'] != null
          ? double.tryParse(json['price'].toString()) ?? 0.0
          : 0.0,
      roomId: json['room_id'] as int?, // Có thể null
      roomName: json['room_name'] as String?,
      billMonth: DateTime.parse(json['bill_month'] as String),
      submittedBy: json['submitted_by'] as int?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.tryParse(json['submitted_at'].toString())
          : null,
      rateDetails: json['rate_details'] != null
          ? RateDetailsModel.fromJson(json['rate_details'] as Map<String, dynamic>)
          : null,
      submitterDetails: json['submitter_details'] != null
          ? SubmitterDetailsModel.fromJson(json['submitter_details'] as Map<String, dynamic>)
          : null,
      monthlyBillId: json['monthly_bill_id'] as int?,
      submitted: json['submitted'] as bool?,
      paymentStatus: json['payment_status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detail_id': detailId,
      'rate_id': rateId,
      'previous_reading': previousReading.toString(),
      'current_reading': currentReading.toString(),
      'price': price.toString(),
      'room_id': roomId,
      'room_name': roomName, // Include room_name in JSON
      'bill_month': billMonth.toIso8601String(),
      'submitted_by': submittedBy,
      'submitted_at': submittedAt?.toIso8601String(),
      'rate_details': rateDetails?.toJson(),
      'submitter_details': submitterDetails?.toJson(),
      'monthly_bill_id': monthlyBillId,
    };
  }

  BillDetail toEntity() {
    return BillDetail(
      detailId: detailId,
      rateId: rateId,
      previousReading: previousReading,
      currentReading: currentReading,
      price: price,
      roomId: roomId,
      roomName: roomName,
      billMonth: billMonth,
      submittedBy: submittedBy,
      submittedAt: submittedAt,
      rateDetails: rateDetails?.toEntity(),
      submitterDetails: submitterDetails?.toEntity(),
      monthlyBillId: monthlyBillId,
      submitted: submitted,
      paymentStatus: paymentStatus,
    );
  }

  @override
  List<Object?> get props => [
    detailId,
    rateId,
    previousReading,
    currentReading,
    price,
    roomId,
    roomName, // Added to props
    billMonth,
    submittedBy,
    submittedAt,
    rateDetails,
    submitterDetails,
    monthlyBillId,
    submitted,
    paymentStatus,
  ];
}

class RateDetailsModel extends Equatable {
  final int rateId;
  final double unitPrice;
  final DateTime? effectiveDate;
  final int serviceId;

  const RateDetailsModel({
    required this.rateId,
    required this.unitPrice,
    this.effectiveDate,
    required this.serviceId,
  });

  factory RateDetailsModel.fromJson(Map<String, dynamic> json) {
    print('Parsing RateDetailsModel: $json');
    try {
      final rateId = json['rate_id'] as int;
      final unitPrice = double.parse(json['unit_price'] as String? ?? '0.00');
      final effectiveDate = json['effective_date'] != null ? DateTime.parse(json['effective_date'] as String) : null;
      final serviceId = json['service_id'] as int;

      return RateDetailsModel(
        rateId: rateId,
        unitPrice: unitPrice,
        effectiveDate: effectiveDate,
        serviceId: serviceId,
      );
    } catch (e) {
      print('Error parsing RateDetailsModel: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'rate_id': rateId,
      'unit_price': unitPrice.toString(),
      'effective_date': effectiveDate?.toIso8601String(),
      'service_id': serviceId,
    };
  }

  RateDetails toEntity() {
    return RateDetails(
      rateId: rateId,
      unitPrice: unitPrice,
      effectiveDate: effectiveDate,
      serviceId: serviceId,
    );
  }

  @override
  List<Object?> get props => [rateId, unitPrice, effectiveDate, serviceId];
}

class SubmitterDetailsModel extends Equatable {
  final int userId;
  final String fullname;
  final String email;

  const SubmitterDetailsModel({
    required this.userId,
    required this.fullname,
    required this.email,
  });

  factory SubmitterDetailsModel.fromJson(Map<String, dynamic> json) {
    print('Parsing SubmitterDetailsModel: $json');
    try {
      final userId = json['user_id'] as int;
      final fullname = json['fullname'] as String? ?? '';
      final email = json['email'] as String? ?? '';

      return SubmitterDetailsModel(
        userId: userId,
        fullname: fullname,
        email: email,
      );
    } catch (e) {
      print('Error parsing SubmitterDetailsModel: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'fullname': fullname,
      'email': email,
    };
  }

  SubmitterDetails toEntity() {
    return SubmitterDetails(
      userId: userId,
      fullname: fullname,
      email: email,
    );
  }

  @override
  List<Object?> get props => [userId, fullname, email];
}
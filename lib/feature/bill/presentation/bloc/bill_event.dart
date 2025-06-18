import 'package:equatable/equatable.dart';

abstract class BillEvent extends Equatable {
  const BillEvent();

  @override
  List<Object?> get props => [];
}

class CreateMonthlyBillsBulk extends BillEvent {
  final DateTime billMonth;
  final List<int>? roomIds;

  const CreateMonthlyBillsBulk({
    required this.billMonth,
    this.roomIds,
  });

  @override
  List<Object?> get props => [billMonth, roomIds];
}

class FetchAllBillDetails extends BillEvent {
  final int page;
  final int limit;
  final String? area;
  final String? service;
  final String? billStatus; // <-- Add this
  final String? paymentStatus;
  final String? search;
  final String? month;
  final String? submissionStatus;

  const FetchAllBillDetails({
    required this.page,
    required this.limit,
    this.area,
    this.service,
    this.billStatus, // <-- Add this
    this.paymentStatus,
    this.search,
    this.month,
    this.submissionStatus,
  });

  @override
  List<Object?> get props => [page, limit, area, service, billStatus, paymentStatus, search, month, submissionStatus];
}

class FetchAllMonthlyBills extends BillEvent {
  final int page;
  final int limit;
  final String? area;
  final String? paymentStatus;
  final String? service;
  final String? month;
  final String? billStatus;
  final String? search;

  const FetchAllMonthlyBills({
    required this.page,
    required this.limit,
    this.area,
    this.paymentStatus,
    this.service,
    this.month,
    this.billStatus,
    this.search,
  });

  @override
  List<Object?> get props => [page, limit, area, paymentStatus, service, month, billStatus, search];
}

class DeletePaidBillsEvent extends BillEvent {
  final List<int> billIds;

  const DeletePaidBillsEvent(this.billIds);

  @override
  List<Object?> get props => [billIds];
}

class DeleteBillDetailEvent extends BillEvent {
  final int detailId;

  const DeleteBillDetailEvent(this.detailId);

  @override
  List<Object?> get props => [detailId];
}

class DeleteMonthlyBillEvent extends BillEvent {
  final int billId;

  const DeleteMonthlyBillEvent(this.billId);

  @override
  List<Object?> get props => [billId];
}

class BillDetailModel {
  // ...existing fields...
  final bool? submitted;
  final String? paymentStatus;

  BillDetailModel({
    // ...existing parameters...
    this.submitted,
    this.paymentStatus,
  });

  factory BillDetailModel.fromJson(Map<String, dynamic> json) {
    return BillDetailModel(
      // ...existing fields...
      submitted: json['submitted'] as bool?,
      paymentStatus: json['payment_status'] as String?,
    );
  }
}
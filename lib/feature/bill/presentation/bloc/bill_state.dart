import 'package:equatable/equatable.dart';
import 'package:datn_web_admin/feature/bill/domain/entities/bill_detail_entity.dart';
import 'package:datn_web_admin/feature/bill/domain/entities/monthly_bill_entity.dart';

abstract class BillState extends Equatable {
  const BillState();

  @override
  List<Object?> get props => [];
}

class BillInitial extends BillState {}

class BillLoading extends BillState {}

class BillError extends BillState {
  final String message;

  const BillError(this.message);

  @override
  List<Object?> get props => [message];
}

class MonthlyBillsLoaded extends BillState {
  final List<MonthlyBill> monthlyBills;
  final int total;
  final int pages;
  final int currentPage;

  const MonthlyBillsLoaded({
    required this.monthlyBills,
    required this.total,
    required this.pages,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [monthlyBills, total, pages, currentPage];
}

class BillDetailsLoaded extends BillState {
  final List<BillDetail> billDetails;
  final int total;
  final int pages;
  final int currentPage;

  const BillDetailsLoaded({
    required this.billDetails,
    required this.total,
    required this.pages,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [billDetails, total, pages, currentPage];
}

class PaidBillsDeleted extends BillState {
  final List<int> deletedMonthlyBillIds;
  final List<int> deletedBillDetailIds;
  final String? message;

  const PaidBillsDeleted({
    required this.deletedMonthlyBillIds,
    required this.deletedBillDetailIds,
    this.message,
  });

  @override
  List<Object?> get props => [deletedMonthlyBillIds, deletedBillDetailIds, message];
}

class MonthlyBillsCreated extends BillState {
  final List<Map<String, dynamic>> billsCreated;
  final List<Map<String, dynamic>> errors;
  final String message;

  const MonthlyBillsCreated({
    required this.billsCreated,
    required this.errors,
    required this.message,
  });

  @override
  List<Object?> get props => [billsCreated, errors, message];
}

class BillDetailDeleted extends BillState {
  final int deletedId;
  final String message;

  const BillDetailDeleted({
    required this.deletedId,
    required this.message,
  });

  @override
  List<Object?> get props => [deletedId, message];
}

class MonthlyBillDeleted extends BillState {
  final int deletedId;
  final String message;

  const MonthlyBillDeleted({
    required this.deletedId,
    required this.message,
  });

  @override
  List<Object?> get props => [deletedId, message];
}

class NotificationSent extends BillState {
  final String message;
  final List<dynamic> notifiedRooms;

  const NotificationSent({
    required this.message,
    this.notifiedRooms = const [],
  });

  @override
  List<Object?> get props => [message, notifiedRooms];
}

class RoomBillDetailsLoaded extends BillState {
  final List<Map<String, dynamic>> roomBillDetails;
  final int roomId;
  final int year;
  final int serviceId;

  const RoomBillDetailsLoaded({
    required this.roomBillDetails,
    required this.roomId,
    required this.year,
    required this.serviceId,
  });

  @override
  List<Object?> get props => [roomBillDetails, roomId, year, serviceId];
}
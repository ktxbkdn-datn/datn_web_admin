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

  const FetchAllBillDetails({this.page = 1, this.limit = 10});

  @override
  List<Object?> get props => [page, limit];
}

class FetchAllMonthlyBills extends BillEvent {
  final int page;
  final int limit;

  const FetchAllMonthlyBills({required this.page, required this.limit});

  @override
  List<Object?> get props => [page, limit];
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
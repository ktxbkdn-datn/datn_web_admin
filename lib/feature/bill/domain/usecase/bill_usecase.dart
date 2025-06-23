import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/feature/bill/domain/entities/monthly_bill_entity.dart';
import 'package:datn_web_admin/feature/bill/domain/repository/bill_repository.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';

class CreateMonthlyBillsBulk {
  final BillRepository repository;

  CreateMonthlyBillsBulk(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required DateTime billMonth,
    List<int>? roomIds,
  }) async {
    return await repository.createMonthlyBillsBulk(
      billMonth: billMonth,
      roomIds: roomIds,
    );
  }
}
class DeleteBillDetail {
  final BillRepository repository;

  DeleteBillDetail(this.repository);

  Future<Either<Failure, void>> call(int detailId) async {
    return await repository.deleteBillDetail(detailId);
  }
}
class DeleteMonthlyBill {
  final BillRepository repository;

  DeleteMonthlyBill(this.repository);

  Future<Either<Failure, void>> call(int billId) async {
    return await repository.deleteMonthlyBill(billId);
  }
}
class DeletePaidBills {
  final BillRepository repository;

  DeletePaidBills(this.repository);

  Future<Either<Failure, Map<String, List<int>>>> call(List<int> billIds) async {
    return await repository.deletePaidBills(billIds);
  }
}
class GetAllMonthlyBills {
  final BillRepository repository;

  GetAllMonthlyBills(this.repository);

  Future<Either<Failure, (List<MonthlyBill>, int)>> call({
    required int page,
    required int limit,
    String? area,
    String? paymentStatus,
    String? service,
    String? month,
    String? billStatus,
    String? search,
  }) async {
    return await repository.getAllMonthlyBills(
      page: page,
      limit: limit,
      area: area,
      paymentStatus: paymentStatus,
      service: service,
      month: month,
      billStatus: billStatus,
      search: search,
    );
  }
}
class GetAllBillDetails {
  final BillRepository repository;

  GetAllBillDetails(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    int page = 1,
    int limit = 20,
    String? area,
    String? service,
    String? billStatus,
    String? paymentStatus,
    String? search,
    String? month,
    String? submissionStatus,
  }) {
    return repository.getAllBillDetails(
      page: page,
      limit: limit,
      area: area,
      service: service,
      billStatus: billStatus,
      paymentStatus: paymentStatus,
      search: search,
      month: month,
      submissionStatus: submissionStatus,
    );
  }
}
class NotifyRemindBillDetail {
  final BillRepository repository;

  NotifyRemindBillDetail(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String billMonth,
  }) async {
    return await repository.notifyRemindBillDetail(
      billMonth: billMonth,
    );
  }
}

class NotifyRemindPayment {
  final BillRepository repository;

  NotifyRemindPayment(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String billMonth,
  }) async {
    return await repository.notifyRemindPayment(
      billMonth: billMonth,
    );
  }
}
class GetRoomBillDetails {
  final BillRepository repository;

  GetRoomBillDetails(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call({
    required int roomId,
    required int year,
    required int serviceId,
  }) async {
    return await repository.getRoomBillDetails(
      roomId: roomId,
      year: year,
      serviceId: serviceId,
    );
  }
}
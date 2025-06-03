import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';
import 'package:datn_web_admin/feature/bill/domain/entities/bill_detail_entity.dart';
import 'package:datn_web_admin/feature/bill/domain/entities/monthly_bill_entity.dart';

abstract class BillRepository {
  Future<Either<Failure, Map<String, dynamic>>> createMonthlyBillsBulk({
    required DateTime billMonth,
    List<int>? roomIds,
  });
  Future<Either<Failure, List<BillDetail>>> getAllBillDetails();
  Future<Either<Failure, (List<MonthlyBill>, int)>> getAllMonthlyBills({required int page, required int limit});
  Future<Either<Failure, void>> deleteMonthlyBill(int billId);
  Future<Either<Failure, Map<String, List<int>>>> deletePaidBills(List<int> billIds);
  Future<Either<Failure, void>> deleteBillDetail(int detailId);
}
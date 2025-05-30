import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';
import 'package:datn_web_admin/feature/bill/domain/repository/bill_repository.dart';

class DeleteMonthlyBill {
  final BillRepository repository;

  DeleteMonthlyBill(this.repository);

  Future<Either<Failure, void>> call(int billId) async {
    return await repository.deleteMonthlyBill(billId);
  }
}
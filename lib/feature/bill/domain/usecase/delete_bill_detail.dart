import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';
import 'package:datn_web_admin/feature/bill/domain/repository/bill_repository.dart';

class DeleteBillDetail {
  final BillRepository repository;

  DeleteBillDetail(this.repository);

  Future<Either<Failure, void>> call(int detailId) async {
    return await repository.deleteBillDetail(detailId);
  }
}
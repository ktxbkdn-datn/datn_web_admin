import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';

import '../repository/bill_repository.dart';

class DeletePaidBills {
  final BillRepository repository;

  DeletePaidBills(this.repository);

  Future<Either<Failure, Map<String, List<int>>>> call(List<int> billIds) async {
    return await repository.deletePaidBills(billIds);
  }
}
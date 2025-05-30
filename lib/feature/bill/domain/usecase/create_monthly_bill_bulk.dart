import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';
import '../repository/bill_repository.dart';

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
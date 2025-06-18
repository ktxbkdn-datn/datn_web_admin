import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';
import '../entities/monthly_bill_entity.dart';
import '../repository/bill_repository.dart';

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
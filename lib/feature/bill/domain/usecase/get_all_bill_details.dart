import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';

import '../entities/bill_detail_entity.dart';
import '../repository/bill_repository.dart';

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
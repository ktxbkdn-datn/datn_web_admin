import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';

import '../entities/bill_detail_entity.dart';
import '../repository/bill_repository.dart';


class GetAllBillDetails {
  final BillRepository repository;

  GetAllBillDetails(this.repository);

  Future<Either<Failure, List<BillDetail>>> call() async {
    return await repository.getAllBillDetails();
  }
}
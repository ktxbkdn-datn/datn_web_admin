// lib/src/features/report/domain/usecases/get_all_report_types.dart
import 'package:dartz/dartz.dart';

import '../../../../../src/core/error/failures.dart';
import '../../entities/report_type_entity.dart';
import '../../repository/rp_type_repository.dart';


class GetAllReportTypes {
  final ReportTypeRepository repository;

  GetAllReportTypes(this.repository);

  Future<Either<Failure, List<ReportTypeEntity>>> call({
    int page = 1,
    int limit = 10,
  }) async {
    return await repository.getAllReportTypes(
      page: page,
      limit: limit,
    );
  }
}
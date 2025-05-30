import 'package:dartz/dartz.dart';

import '../../../../../src/core/error/failures.dart';
import '../../entities/report_type_entity.dart';
import '../../repository/rp_type_repository.dart';

class UpdateReportType {
  final ReportTypeRepository repository;

  UpdateReportType(this.repository);

  Future<Either<Failure, ReportTypeEntity>> call({
    required int reportTypeId,
    required String name,
  }) async {
    return await repository.updateReportType(
      reportTypeId: reportTypeId,
      name: name,
    );
  }
}
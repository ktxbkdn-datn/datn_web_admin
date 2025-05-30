import 'package:dartz/dartz.dart';

import '../../../../../src/core/error/failures.dart';
import '../../entities/report_type_entity.dart';
import '../../repository/rp_type_repository.dart';

class CreateReportType {
  final ReportTypeRepository repository;

  CreateReportType(this.repository);

  Future<Either<Failure, ReportTypeEntity>> call(String name) async {
    return await repository.createReportType(name);
  }
}
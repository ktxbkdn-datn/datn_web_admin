// lib/src/features/report/domain/usecases/get_report_by_id.dart
import 'package:dartz/dartz.dart';

import '../../../../../src/core/error/failures.dart';
import '../../entities/report_entity.dart';
import '../../repository/report_repository.dart';

class GetReportById {
  final ReportRepository repository;

  GetReportById(this.repository);

  Future<Either<Failure, ReportEntity>> call(int reportId) async {
    return await repository.getReportById(reportId);
  }
}
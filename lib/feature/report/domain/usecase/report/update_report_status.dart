// lib/src/features/report/domain/usecases/update_report_status.dart
import 'package:dartz/dartz.dart';
import '../../../../../src/core/error/failures.dart';
import '../../entities/report_entity.dart';
import '../../repository/report_repository.dart';


class UpdateReportStatus {
  final ReportRepository repository;

  UpdateReportStatus(this.repository);

  Future<Either<Failure, ReportEntity>> call({
    required int reportId,
    required String status,
  }) async {
    return await repository.updateReportStatus(
      reportId: reportId,
      status: status,
    );
  }
}
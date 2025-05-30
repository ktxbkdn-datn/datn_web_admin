// lib/src/features/report/domain/usecases/delete_report.dart
import 'package:dartz/dartz.dart';
import '../../../../../src/core/error/failures.dart';
import '../../repository/report_repository.dart';

class DeleteReport {
  final ReportRepository repository;

  DeleteReport(this.repository);

  Future<Either<Failure, Unit>> call(int reportId) async {
    return await repository.deleteReport(reportId);
  }
}
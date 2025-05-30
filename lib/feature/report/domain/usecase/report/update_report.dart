// lib/src/features/report/domain/usecases/update_report.dart
import 'package:dartz/dartz.dart';
import '../../../../../src/core/error/failures.dart';
import '../../entities/report_entity.dart';
import '../../repository/report_repository.dart';


class UpdateReport {
  final ReportRepository repository;

  UpdateReport(this.repository);

  Future<Either<Failure, ReportEntity>> call({
    required int reportId,
    required int roomId,
    required int reportTypeId,
    required String description,
    required String status,
  }) async {
    return await repository.updateReport(
      reportId: reportId,
      roomId: roomId,
      reportTypeId: reportTypeId,
      description: description,
      status: status,
    );
  }
}
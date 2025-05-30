// lib/src/features/report/domain/usecases/delete_report_type.dart
import 'package:dartz/dartz.dart';
import '../../../../../src/core/error/failures.dart';
import '../../repository/rp_type_repository.dart';


class DeleteReportType {
  final ReportTypeRepository repository;

  DeleteReportType(this.repository);

  Future<Either<Failure, Unit>> call(int reportTypeId) async {
    return await repository.deleteReportType(reportTypeId);
  }
}
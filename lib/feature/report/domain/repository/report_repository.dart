import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entities/report_entity.dart';

abstract class ReportRepository {
  Future<Either<Failure, (List<ReportEntity>, int)>> getAllReports({
    int page = 1,
    int limit = 10,
    int? userId,
    int? roomId,
    String? status,
    int? reportTypeId,
    String? searchQuery,
  });

  Future<Either<Failure, ReportEntity>> getReportById(int reportId);

  Future<Either<Failure, ReportEntity>> updateReport({
    required int reportId,
    required int roomId,
    required int reportTypeId,
    required String description,
    required String status,
  });

  Future<Either<Failure, ReportEntity>> updateReportStatus({
    required int reportId,
    required String status,
  });

  Future<Either<Failure, Unit>> deleteReport(int reportId);
}
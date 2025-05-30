// lib/src/features/report/domain/repositories/report_type_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entities/report_type_entity.dart';

abstract class ReportTypeRepository {
  Future<Either<Failure, List<ReportTypeEntity>>> getAllReportTypes({
    int page,
    int limit,
  });

  Future<Either<Failure, ReportTypeEntity>> createReportType(String name);

  Future<Either<Failure, ReportTypeEntity>> updateReportType({
    required int reportTypeId,
    required String name,
  });

  Future<Either<Failure, Unit>> deleteReportType(int reportTypeId);
}
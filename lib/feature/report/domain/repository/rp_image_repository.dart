// lib/src/features/report/domain/repositories/report_image_repository.dart
import 'package:dartz/dartz.dart';

import '../../../../src/core/error/failures.dart';
import '../entities/report_image_entity.dart';

abstract class ReportImageRepository {
  Future<Either<Failure, List<ReportImageEntity>>> getReportImages(int reportId);

  Future<Either<Failure, Unit>> deleteReportImage({
    required int reportId,
    required int imageId,
  });
}
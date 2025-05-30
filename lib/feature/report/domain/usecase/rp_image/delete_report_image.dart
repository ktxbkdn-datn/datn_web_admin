// lib/src/features/report/domain/usecases/get_report_images.dart
import 'package:dartz/dartz.dart';

import '../../../../../src/core/error/failures.dart';
import '../../entities/report_image_entity.dart';
import '../../repository/rp_image_repository.dart';


class GetReportImages {
  final ReportImageRepository repository;

  GetReportImages(this.repository);

  Future<Either<Failure, List<ReportImageEntity>>> call(int reportId) async {
    return await repository.getReportImages(reportId);
  }
}
// lib/src/features/report/domain/usecases/delete_report_image.dart
import 'package:dartz/dartz.dart';

import '../../../../../src/core/error/failures.dart';
import '../../repository/rp_image_repository.dart';


class DeleteReportImage {
  final ReportImageRepository repository;

  DeleteReportImage(this.repository);

  Future<Either<Failure, Unit>> call({
    required int reportId,
    required int imageId,
  }) async {
    return await repository.deleteReportImage(
      reportId: reportId,
      imageId: imageId,
    );
  }
}
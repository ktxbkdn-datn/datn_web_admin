// lib/src/features/report/data/repositories/report_image_repository_impl.dart
import 'package:dartz/dartz.dart';

import '../../../../src/core/error/failures.dart';
import '../../domain/entities/report_image_entity.dart';

import '../../domain/repository/rp_image_repository.dart';
import '../datasource/report_image_remote_data_source.dart';


class ReportImageRepositoryImpl implements ReportImageRepository {
  final ReportImageRemoteDataSource remoteDataSource;

  ReportImageRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ReportImageEntity>>> getReportImages(int reportId) async {
    try {
      final remoteImages = await remoteDataSource.getReportImages(reportId);
      return Right(remoteImages);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteReportImage({
    required int reportId,
    required int imageId,
  }) async {
    try {
      await remoteDataSource.deleteReportImage(
        reportId: reportId,
        imageId: imageId,
      );
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
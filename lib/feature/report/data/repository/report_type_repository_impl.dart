// lib/src/features/report/data/repositories/report_type_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../../domain/entities/report_type_entity.dart';
import '../../domain/repository/rp_type_repository.dart';
import '../datasource/report_type_remote_data_source.dart';


class ReportTypeRepositoryImpl implements ReportTypeRepository {
  final ReportTypeRemoteDataSource remoteDataSource;

  ReportTypeRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ReportTypeEntity>>> getAllReportTypes({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final remoteReportTypes = await remoteDataSource.getAllReportTypes(
        page: page,
        limit: limit,
      );
      return Right(remoteReportTypes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReportTypeEntity>> createReportType(String name) async {
    try {
      final remoteReportType = await remoteDataSource.createReportType(name);
      return Right(remoteReportType);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReportTypeEntity>> updateReportType({
    required int reportTypeId,
    required String name,
  }) async {
    try {
      final remoteReportType = await remoteDataSource.updateReportType(
        reportTypeId: reportTypeId,
        name: name,
      );
      return Right(remoteReportType);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteReportType(int reportTypeId) async {
    try {
      await remoteDataSource.deleteReportType(reportTypeId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
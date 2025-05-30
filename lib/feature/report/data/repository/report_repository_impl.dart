// lib/src/features/report/data/repositories/report_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/repository/report_repository.dart';
import '../datasource/report_remote_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ReportEntity>>> getAllReports({
    int page = 1,
    int limit = 10,
    int? userId,
    int? roomId,
    String? status,
  }) async {
    try {
      print('Fetching all reports with params: page=$page, limit=$limit, userId=$userId, roomId=$roomId, status=$status');
      final remoteReports = await remoteDataSource.getAllReports(
        page: page,
        limit: limit,
        userId: userId,
        roomId: roomId,
        status: status,
      );
      print('Received reports from remote data source: ${remoteReports.map((report) => report.toJson()).toList()}');
      return Right(remoteReports);
    } catch (e) {
      print('Error fetching all reports: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReportEntity>> getReportById(int reportId) async {
    try {
      print('Fetching report by ID: $reportId');
      final remoteReport = await remoteDataSource.getReportById(reportId);
      print('Received report from remote data source: ${remoteReport.toJson()}');
      return Right(remoteReport);
    } catch (e) {
      print('Error fetching report $reportId: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReportEntity>> updateReport({
    required int reportId,
    required int roomId,
    required int reportTypeId,
    required String description,
    required String status,
  }) async {
    try {
      print('Updating report $reportId with data: roomId=$roomId, reportTypeId=$reportTypeId, description=$description, status=$status');
      final remoteReport = await remoteDataSource.updateReport(
        reportId: reportId,
        roomId: roomId,
        reportTypeId: reportTypeId,
        description: description,
        status: status,
      );
      print('Updated report from remote data source: ${remoteReport.toJson()}');
      return Right(remoteReport);
    } catch (e) {
      print('Error updating report $reportId: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReportEntity>> updateReportStatus({
    required int reportId,
    required String status,
  }) async {
    try {
      print('Updating report status for report $reportId to: $status');
      final remoteReport = await remoteDataSource.updateReportStatus(
        reportId: reportId,
        status: status,
      );
      print('Updated report status from remote data source: ${remoteReport.toJson()}');
      return Right(remoteReport);
    } catch (e) {
      print('Error updating report status for report $reportId: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteReport(int reportId) async {
    try {
      print('Deleting report $reportId');
      await remoteDataSource.deleteReport(reportId);
      print('Successfully deleted report $reportId');
      return const Right(unit);
    } catch (e) {
      print('Error deleting report $reportId: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
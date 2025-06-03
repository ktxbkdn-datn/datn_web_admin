import 'package:dartz/dartz.dart';
import '../../../../../src/core/error/failures.dart';
import '../../entities/report_entity.dart';
import '../../repository/report_repository.dart';

class GetAllReports {
  final ReportRepository repository;

  GetAllReports(this.repository);

  Future<Either<Failure, (List<ReportEntity>, int)>> call({
    int page = 1,
    int limit = 10,
    int? userId,
    int? roomId,
    String? status,
    int? reportTypeId,
    String? searchQuery,
  }) async {
    return await repository.getAllReports(
      page: page,
      limit: limit,
      userId: userId,
      roomId: roomId,
      status: status,
      reportTypeId: reportTypeId,
      searchQuery: searchQuery,
    );
  }
}
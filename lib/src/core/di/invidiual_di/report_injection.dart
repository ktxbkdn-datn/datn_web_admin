// lib/src/injection/report_injection.dart
import 'package:get_it/get_it.dart';

import '../../../../feature/report/data/datasource/report_remote_data_source.dart';
import '../../../../feature/report/data/repository/report_repository_impl.dart';
import '../../../../feature/report/domain/repository/report_repository.dart';
import '../../../../feature/report/domain/usecase/report/delete_report.dart';
import '../../../../feature/report/domain/usecase/report/get_all_reports.dart';
import '../../../../feature/report/domain/usecase/report/get_report_by_id.dart';
import '../../../../feature/report/domain/usecase/report/update_report.dart';
import '../../../../feature/report/domain/usecase/report/update_report_status.dart';
import '../../../../feature/report/presentation/bloc/report/report_bloc.dart';
import '../../network/api_client.dart';


final getIt = GetIt.instance;

void registerReportDependencies() {
  getIt.registerSingleton<ReportRemoteDataSource>(
      ReportRemoteDataSourceImpl(getIt<ApiService>())
  );
  getIt.registerSingleton<ReportRepository>(
      ReportRepositoryImpl(getIt<ReportRemoteDataSource>())
  );
  getIt.registerSingleton<GetAllReports>(
      GetAllReports(getIt<ReportRepository>())
  );
  getIt.registerSingleton<GetReportById>(
      GetReportById(getIt<ReportRepository>())
  );
  getIt.registerSingleton<UpdateReport>(
      UpdateReport(getIt<ReportRepository>())
  );
  getIt.registerSingleton<UpdateReportStatus>(
      UpdateReportStatus(getIt<ReportRepository>())
  );
  getIt.registerSingleton<DeleteReport>(
      DeleteReport(getIt<ReportRepository>())
  );
  getIt.registerFactory<ReportBloc>(() => ReportBloc(
    getAllReports: getIt<GetAllReports>(),
    getReportById: getIt<GetReportById>(),
    updateReport: getIt<UpdateReport>(),
    updateReportStatus: getIt<UpdateReportStatus>(),
    deleteReport: getIt<DeleteReport>(),
  ));
}
// lib/src/injection/report_type_injection.dart
import 'package:get_it/get_it.dart';

import '../../../../feature/report/data/datasource/report_type_remote_data_source.dart';
import '../../../../feature/report/data/repository/report_type_repository_impl.dart';
import '../../../../feature/report/domain/repository/rp_type_repository.dart';
import '../../../../feature/report/domain/usecase/rp_type/create_report_type.dart';
import '../../../../feature/report/domain/usecase/rp_type/delete_report_type.dart';
import '../../../../feature/report/domain/usecase/rp_type/get_all_report_types.dart';
import '../../../../feature/report/domain/usecase/rp_type/update_report_type.dart';
import '../../../../feature/report/presentation/bloc/rp_type/rp_type_bloc.dart';
import '../../network/api_client.dart';


final getIt = GetIt.instance;

void registerReportTypeDependencies() {
  getIt.registerSingleton<ReportTypeRemoteDataSource>(
      ReportTypeRemoteDataSourceImpl(getIt<ApiService>())
  );
  getIt.registerSingleton<ReportTypeRepository>(
      ReportTypeRepositoryImpl(getIt<ReportTypeRemoteDataSource>())
  );
  getIt.registerSingleton<GetAllReportTypes>(
      GetAllReportTypes(getIt<ReportTypeRepository>())
  );
  getIt.registerSingleton<CreateReportType>(
      CreateReportType(getIt<ReportTypeRepository>())
  );
  getIt.registerSingleton<UpdateReportType>(
      UpdateReportType(getIt<ReportTypeRepository>())
  );
  getIt.registerSingleton<DeleteReportType>(
      DeleteReportType(getIt<ReportTypeRepository>())
  );
  getIt.registerFactory<ReportTypeBloc>(() => ReportTypeBloc(
    getAllReportTypes: getIt<GetAllReportTypes>(),
    createReportType: getIt<CreateReportType>(),
    updateReportType: getIt<UpdateReportType>(),
    deleteReportType: getIt<DeleteReportType>(),
  ));
}
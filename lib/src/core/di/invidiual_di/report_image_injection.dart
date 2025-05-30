// lib/src/injection/report_image_injection.dart
import 'package:get_it/get_it.dart';

import '../../../../feature/report/data/datasource/report_image_remote_data_source.dart';
import '../../../../feature/report/data/repository/report_image_repository_impl.dart';
import '../../../../feature/report/domain/repository/rp_image_repository.dart';
import '../../../../feature/report/domain/usecase/rp_image/delete_report_image.dart';
import '../../../../feature/report/domain/usecase/rp_image/get_report_images.dart';
import '../../../../feature/report/presentation/bloc/rp_image/rp_image_bloc.dart';
import '../../network/api_client.dart';


final getIt = GetIt.instance;

void registerReportImageDependencies() {
  getIt.registerSingleton<ReportImageRemoteDataSource>(
      ReportImageRemoteDataSourceImpl(getIt<ApiService>())
  );
  getIt.registerSingleton<ReportImageRepository>(
      ReportImageRepositoryImpl(getIt<ReportImageRemoteDataSource>())
  );
  getIt.registerSingleton<GetReportImages>(
      GetReportImages(getIt<ReportImageRepository>())
  );
  getIt.registerSingleton<DeleteReportImage>(
      DeleteReportImage(getIt<ReportImageRepository>())
  );
  getIt.registerFactory<ReportImageBloc>(() => ReportImageBloc(
    getReportImages: getIt<GetReportImages>(),
    deleteReportImage: getIt<DeleteReportImage>(),
  ));
}
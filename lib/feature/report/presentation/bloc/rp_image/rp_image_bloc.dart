// lib/src/features/report/presentations/bloc_ri/rp_image_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:datn_web_admin/feature/report/presentation/bloc/rp_image/rp_image_event.dart';
import 'package:datn_web_admin/feature/report/presentation/bloc/rp_image/rp_image_state.dart';


import '../../../domain/usecase/rp_image/delete_report_image.dart';
import '../../../domain/usecase/rp_image/get_report_images.dart';


class ReportImageBloc extends Bloc<ReportImageEvent, ReportImageState> {
  final GetReportImages getReportImages;
  final DeleteReportImage deleteReportImage;
  final Map<int, List<String>> _imageDataCache = {};  // Cache danh sách imageUrl

  ReportImageBloc({
    required this.getReportImages,
    required this.deleteReportImage,
  }) : super(ReportImageInitial()) {
    on<GetReportImagesEvent>(_onGetReportImages);
    on<DeleteReportImageEvent>(_onDeleteReportImage);
    on<ResetReportImageStateEvent>(_onResetReportImageState);
  }

  Future<void> _onGetReportImages(GetReportImagesEvent event, Emitter<ReportImageState> emit) async {
    emit(ReportImageLoading());
    final result = await getReportImages(event.reportId);
    result.fold(
          (failure) {
        if (failure.message.contains('Không tìm thấy media cho báo cáo này')) {
          _imageDataCache[event.reportId] = [];
          emit(const ReportImagesLoaded(imageUrls: []));
        } else {
          emit(ReportImageError(message: failure.message));
        }
      },
          (imageList) {
        // Chỉ lấy danh sách imageUrl từ danh sách ReportImageModel
        final imageUrls = imageList.map((image) => image.imageUrl).toList();
        _imageDataCache[event.reportId] = imageUrls;
        emit(ReportImagesLoaded(imageUrls: imageUrls));
      },
    );
  }

  Future<void> _onDeleteReportImage(DeleteReportImageEvent event, Emitter<ReportImageState> emit) async {
    emit(ReportImageLoading());
    final result = await deleteReportImage(
      reportId: event.reportId,
      imageId: event.imageId,
    );
    result.fold(
          (failure) {
        emit(ReportImageError(message: failure.message));
      },
          (_) {
        _imageDataCache.remove(event.reportId);
        add(GetReportImagesEvent(event.reportId));
      },
    );
  }

  Future<void> _onResetReportImageState(ResetReportImageStateEvent event, Emitter<ReportImageState> emit) async {
    emit(ReportImageInitial());
    _imageDataCache.clear();
  }
}
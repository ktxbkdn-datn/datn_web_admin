// lib/src/features/report/presentations/bloc_ri/report_image_event.dart
import 'package:equatable/equatable.dart';

abstract class ReportImageEvent extends Equatable {
  const ReportImageEvent();

  @override
  List<Object?> get props => [];
}

class GetReportImagesEvent extends ReportImageEvent {
  final int reportId;

  const GetReportImagesEvent(this.reportId);

  @override
  List<Object?> get props => [reportId];
}

class DeleteReportImageEvent extends ReportImageEvent {
  final int reportId;
  final int imageId;

  const DeleteReportImageEvent({required this.reportId, required this.imageId});

  @override
  List<Object?> get props => [reportId, imageId];
}

class ResetReportImageStateEvent extends ReportImageEvent {
  const ResetReportImageStateEvent();

  @override
  List<Object?> get props => [];
}
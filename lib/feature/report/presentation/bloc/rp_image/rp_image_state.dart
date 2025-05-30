// lib/src/features/report/presentations/bloc_ri/rp_image_state.dart
import 'package:equatable/equatable.dart';

abstract class ReportImageState extends Equatable {
  const ReportImageState();

  @override
  List<Object> get props => [];
}

class ReportImageInitial extends ReportImageState {}

class ReportImageLoading extends ReportImageState {}

class ReportImagesLoaded extends ReportImageState {
  final List<String> imageUrls;  // Chỉ lưu danh sách imageUrl dạng String

  const ReportImagesLoaded({required this.imageUrls});

  @override
  List<Object> get props => [imageUrls];
}

class ReportImageError extends ReportImageState {
  final String message;

  const ReportImageError({required this.message});

  @override
  List<Object> get props => [message];
}

class ReportImageDeleted extends ReportImageState {}
import 'package:equatable/equatable.dart';

abstract class RoomImageState extends Equatable {
  const RoomImageState();

  @override
  List<Object> get props => [];
}

class RoomImageInitial extends RoomImageState {}

class RoomImageLoading extends RoomImageState {}

class RoomImagesLoaded extends RoomImageState {
  final List<Map<String, dynamic>> images; // {imageId, imageUrl}

  const RoomImagesLoaded({required this.images});

  @override
  List<Object> get props => [images];
}

class RoomImagesUploaded extends RoomImageState {
  final List<String> imageUrls;

  const RoomImagesUploaded({required this.imageUrls});

  @override
  List<Object> get props => [imageUrls];
}

class RoomImageError extends RoomImageState {
  final String message;

  const RoomImageError({required this.message});

  @override
  List<Object> get props => [message];
}

class RoomImageDeleted extends RoomImageState {}

class RoomImagesReordered extends RoomImageState {}
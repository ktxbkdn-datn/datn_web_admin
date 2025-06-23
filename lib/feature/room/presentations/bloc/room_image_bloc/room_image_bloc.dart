import 'package:bloc/bloc.dart';
import 'package:datn_web_admin/feature/room/domain/usecases/room_image_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/common/constants/api_string.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/room_image_bloc/room_image_state.dart';



part 'room_image_event.dart';

const String baseUrl = APIbaseUrl;

class RoomImageBloc extends Bloc<RoomImageEvent, RoomImageState> {
  final GetRoomImages getRoomImages;
  final UploadRoomImages uploadRoomImages;
  final DeleteRoomImage deleteRoomImage;
  final DeleteMoreRoomImage deleteMoreRoomImage;
  final ReorderRoomImages reorderRoomImages;
  final Map<int, List<Map<String, dynamic>>> _imageDataCache = {};

  RoomImageBloc({
    required this.getRoomImages,
    required this.uploadRoomImages,
    required this.deleteRoomImage,
    required this.deleteMoreRoomImage,
    required this.reorderRoomImages,
  }) : super(RoomImageInitial()) {
    on<GetRoomImagesEvent>(_onGetRoomImages);
    on<UploadRoomImagesEvent>(_onUploadRoomImages);
    on<DeleteRoomImageEvent>(_onDeleteRoomImage);
    on<DeleteRoomImagesBatchEvent>(_onDeleteRoomImagesBatch);
    on<ReorderRoomImagesEvent>(_onReorderRoomImages);
    on<ResetRoomImageStateEvent>(_onResetRoomImageState);
  }

  Future<void> _onGetRoomImages(GetRoomImagesEvent event, Emitter<RoomImageState> emit) async {
    emit(RoomImageLoading());
    final result = await getRoomImages(event.roomId);
    print('Result type: ${result.runtimeType}, value: $result');
    result.fold(
          (failure) {
        print('Failure: ${failure.message}');
        if (failure.message.contains('Không tìm thấy ảnh cho phòng này')) {
          _imageDataCache[event.roomId] = [];
          emit(RoomImagesLoaded(images: []));
        } else {
          emit(RoomImageError(message: failure.message));
        }
      },
          (imageList) {
        print('Image List: $imageList');
        _imageDataCache[event.roomId] = imageList;
        print('Emitting RoomImagesLoaded with images: $imageList');
        emit(RoomImagesLoaded(images: imageList));
      },
    );
  }

  Future<void> _onUploadRoomImages(UploadRoomImagesEvent event, Emitter<RoomImageState> emit) async {
    emit(RoomImageLoading());
    final result = await uploadRoomImages(
      roomId: event.roomId,
      images: event.images,
    );
    result.fold(
          (failure) {
        print('Upload Images Failure: ${failure.message}');
        emit(RoomImageError(message: failure.message));
      },
          (uploadedImages) {
        print('Uploaded Images: $uploadedImages');
        print('Uploaded Images Type: ${uploadedImages.runtimeType}');

        List<String> imageUrls = [];
        for (var imageData in uploadedImages) {
          print('Processing imageData: $imageData');
          final imageUrl = imageData['imageUrl'] as String?;
          if (imageUrl == null) {
            print('Error: imageData has null image_url: $imageData');
            emit(RoomImageError(message: 'Invalid image data: image_url is null'));
            return;
          }
          imageUrls.add(imageUrl);
        }

        print('Emitting RoomImagesUploaded with imageUrls: $imageUrls');
        emit(RoomImagesUploaded(imageUrls: imageUrls));
        _imageDataCache.remove(event.roomId);
        add(GetRoomImagesEvent(event.roomId));
      },
    );
  }

  Future<void> _onDeleteRoomImage(DeleteRoomImageEvent event, Emitter<RoomImageState> emit) async {
    emit(RoomImageLoading());
    final result = await deleteRoomImage(
      roomId: event.roomId,
      imageId: event.imageId,
    );
    result.fold(
          (failure) {
        print('Delete Image Failure: ${failure.message}');
        emit(RoomImageError(message: failure.message));
      },
          (_) {
        _imageDataCache.remove(event.roomId);
        add(GetRoomImagesEvent(event.roomId));
      },
    );
  }

  Future<void> _onDeleteRoomImagesBatch(DeleteRoomImagesBatchEvent event, Emitter<RoomImageState> emit) async {
    emit(RoomImageLoading());
    final result = await deleteMoreRoomImage(
      roomId: event.roomId,
      imageIds: event.imageIds,
    );
    result.fold(
          (failure) {
        print('Batch Delete Images Failure: ${failure.message}');
        emit(RoomImageError(message: failure.message));
      },
          (_) {
        _imageDataCache.remove(event.roomId);
        add(GetRoomImagesEvent(event.roomId));
      },
    );
  }

  Future<void> _onReorderRoomImages(ReorderRoomImagesEvent event, Emitter<RoomImageState> emit) async {
    emit(RoomImageLoading());
    final result = await reorderRoomImages(
      roomId: event.roomId,
      imageIds: event.imageIds,
    );
    result.fold(
          (failure) {
        print('Reorder Images Failure: ${failure.message}');
        emit(RoomImageError(message: failure.message));
      },
          (_) {
        _imageDataCache.remove(event.roomId);
        add(GetRoomImagesEvent(event.roomId));
      },
    );
  }

  Future<void> _onResetRoomImageState(ResetRoomImageStateEvent event, Emitter<RoomImageState> emit) async {
    emit(RoomImageInitial());
    _imageDataCache.clear();
  }
}
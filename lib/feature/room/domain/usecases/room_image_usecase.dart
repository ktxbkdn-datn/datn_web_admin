import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/feature/room/domain/repositories/room_image_repository.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';

class GetRoomImages {
  final RoomImageRepository repository;

  GetRoomImages(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call(int roomId) async {
    return await repository.getRoomImages(roomId);
  }
}

class UploadRoomImages {
  final RoomImageRepository repository;

  UploadRoomImages(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call({
    required int roomId,
    required List<Map<String, dynamic>> images,
  }) async {
    return await repository.uploadRoomImages(roomId: roomId, images: images);
  }
}
class ReorderRoomImages {
  final RoomImageRepository repository;

  ReorderRoomImages(this.repository);

  Future<Either<Failure, void>> call({
    required int roomId,
    required List<int> imageIds,
  }) async {
    return await repository.reorderRoomImages(
      roomId: roomId,
      imageIds: imageIds,
    );
  }
}
class DeleteMoreRoomImage{
  final RoomImageRepository repository;

  DeleteMoreRoomImage(this.repository);

  Future<Either<Failure, Unit>> call({
    required int roomId,
    required List<int> imageIds,
  }) async {
    return await repository.deleteRoomImagesBatch(
      roomId: roomId,
      imageIds: imageIds,
    );
  }
}
class DeleteRoomImage {
  final RoomImageRepository repository;

  DeleteRoomImage(this.repository);

  Future<Either<Failure, Unit>> call({
    required int roomId,
    required int imageId,
  }) async {
    return await repository.deleteRoomImage(
      roomId: roomId,
      imageId: imageId,
    );
  }


}
import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/feature/room/domain/repositories/room_image_repository.dart';
import '../../../../src/core/error/failures.dart';

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
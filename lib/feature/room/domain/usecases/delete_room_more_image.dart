import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/feature/room/domain/repositories/room_image_repository.dart';

import '../../../../src/core/error/failures.dart';


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
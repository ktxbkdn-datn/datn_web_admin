// lib/src/features/room/domain/usecases/delete_room_image.dart
import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../repositories/room_image_repository.dart';
import '../repositories/room_repository.dart';

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
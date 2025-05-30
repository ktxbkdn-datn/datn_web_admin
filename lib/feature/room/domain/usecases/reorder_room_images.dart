// lib/src/features/room/domain/usecases/reorder_room_images.dart
import 'package:dartz/dartz.dart';

import '../../../../src/core/error/failures.dart';
import '../repositories/room_image_repository.dart';
import '../repositories/room_repository.dart';

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
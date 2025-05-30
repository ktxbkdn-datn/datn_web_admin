// lib/src/features/room/domain/repositories/room_image_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entities/room_image_entity.dart';

abstract class RoomImageRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getRoomImages(int roomId);

  Future<Either<Failure, List<Map<String, dynamic>>>> uploadRoomImages({
    required int roomId,
    required List<Map<String, dynamic>> images,
  });

  Future<Either<Failure, Unit>> deleteRoomImage({
    required int roomId,
    required int imageId,
  });

  Future<Either<Failure, Unit>> reorderRoomImages({
    required int roomId,
    required List<int> imageIds,
  });

Future<Either<Failure, Unit>> deleteRoomImagesBatch({
  required int roomId,
  required List<int> imageIds,
});

}
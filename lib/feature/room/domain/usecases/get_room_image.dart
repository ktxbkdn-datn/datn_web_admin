// lib/src/features/room/domain/usecases/get_room_images.dart
import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entities/room_image_entity.dart';
import '../repositories/room_image_repository.dart';
import '../repositories/room_repository.dart';

class GetRoomImages {
  final RoomImageRepository repository;

  GetRoomImages(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call(int roomId) async {
    return await repository.getRoomImages(roomId);
  }
}
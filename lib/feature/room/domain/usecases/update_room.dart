// lib/src/features/room/domain/usecases/update_room.dart
import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entities/room_entity.dart';
import '../repositories/room_repository.dart';

class UpdateRoom {
  final RoomRepository repository;

  UpdateRoom(this.repository);

  Future<Either<Failure, RoomEntity>> call({
    required int roomId,
    String? name,
    int? capacity,
    double? price,
    String? description,
    String? status,
    int? areaId,
    List<int>? imageIdsToDelete,
    List<Map<String, dynamic>>? newImages,
  }) async {
    return await repository.updateRoom(
      roomId: roomId,
      name: name,
      capacity: capacity,
      price: price,
      description: description,
      status: status,
      areaId: areaId,
      imageIdsToDelete: imageIdsToDelete,
      newImages: newImages,
    );
  }
}
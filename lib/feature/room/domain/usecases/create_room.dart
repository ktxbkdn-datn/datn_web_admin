import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entities/room_entity.dart';
import '../repositories/room_repository.dart';

class CreateRoom {
  final RoomRepository repository;

  CreateRoom(this.repository);

  Future<Either<Failure, RoomEntity>> call({
    required String name,
    required int capacity,
    required double price,
    required int areaId,
    String? description,
    List<Map<String, dynamic>>? images,
  }) async {
    return await repository.createRoom(
      name: name,
      capacity: capacity,
      price: price,
      areaId: areaId,
      description: description,
      images: images,
    );
  }
}
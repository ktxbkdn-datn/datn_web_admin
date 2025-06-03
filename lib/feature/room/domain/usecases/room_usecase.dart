import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/feature/room/domain/entities/room_entity.dart';
import 'package:datn_web_admin/feature/room/domain/repositories/room_repository.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';

class GetRoomById {
  final RoomRepository repository;

  GetRoomById(this.repository);

  Future<Either<Failure, RoomEntity>> call(int roomId) async {
    return await repository.getRoomById(roomId);
  }
}

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

class GetAllRooms {
  final RoomRepository repository;

  GetAllRooms(this.repository);

  Future<Either<Failure, List<RoomEntity>>> call({
    required int page,
    required int limit,
    int? minCapacity,
    int? maxCapacity,
    double? minPrice,
    double? maxPrice,
    bool? available,
    String? search,
    int? areaId,
  }) async {
    return await repository.getAllRooms(
      page: page,
      limit: limit,
      minCapacity: minCapacity,
      maxCapacity: maxCapacity,
      minPrice: minPrice,
      maxPrice: maxPrice,
      available: available,
      search: search,
      areaId: areaId,
    );
  }
}

class DeleteRoom {
  final RoomRepository repository;

  DeleteRoom(this.repository);

  Future<Either<Failure, void>> call(int roomId) async {
    return await repository.deleteRoom(roomId);
  }
}

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
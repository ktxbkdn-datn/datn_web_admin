import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/feature/room/domain/entities/room_entity.dart';
import 'package:datn_web_admin/feature/room/domain/repositories/room_repository.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';
import 'dart:typed_data';

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

  Future<Either<Failure, Map<String, dynamic>>> call({
    required int page,
    required int limit,
    int? minCapacity,
    int? maxCapacity,
    double? minPrice,
    double? maxPrice,
    bool? available,
    String? search,
    int? areaId,
    String? searchUser,
  }) {
    return repository.getAllRooms(
      page: page,
      limit: limit,
      minCapacity: minCapacity,
      maxCapacity: maxCapacity,
      minPrice: minPrice,
      maxPrice: maxPrice,
      available: available,
      search: search,
      areaId: areaId,
      searchUser: searchUser,
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



// Thêm usecase lấy danh sách user trong phòng
class GetUsersInRoom {
  final RoomRepository repository;
  GetUsersInRoom(this.repository);

  Future<List<Map<String, dynamic>>> call(int roomId) {
    return repository.getUsersInRoom(roomId);
  }
}

// Thêm usecase export file Excel
class ExportUsersInRoom {
  final RoomRepository repository;
  ExportUsersInRoom(this.repository);

  Future<Uint8List> call(int roomId) {
    return repository.exportUsersInRoom(roomId);
  }
}
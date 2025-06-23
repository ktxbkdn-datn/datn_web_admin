import 'package:dartz/dartz.dart';
import 'dart:typed_data';
import '../../../../src/core/error/failures.dart';
import '../entities/room_entity.dart';

abstract class RoomRepository {
  Future<Either<Failure, Map<String, dynamic>>> getAllRooms({
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
  });

  Future<Either<Failure, RoomEntity>> getRoomById(int roomId);

  Future<Either<Failure, RoomEntity>> createRoom({
    required String name,
    required int capacity,
    required double price,
    required int areaId,
    String? description,
    List<Map<String, dynamic>>? images,
  });

  Future<Either<Failure, RoomEntity>> updateRoom({
    required int roomId,
    String? name,
    int? capacity,
    double? price,
    String? description,
    String? status,
    int? areaId,
    List<int>? imageIdsToDelete,
    List<Map<String, dynamic>>? newImages,
  });

  Future<Either<Failure, void>> deleteRoom(int roomId);

  // Thêm vào interface
  Future<List<Map<String, dynamic>>> getUsersInRoom(int roomId);
  Future<Uint8List> exportUsersInRoom(int roomId);
}
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/repositories/room_repository.dart';
import '../datasources/room_datasource.dart';
import '../models/room_model.dart';

class RoomRepositoryImpl implements RoomRepository {
  final RoomDataSource roomDataSource;

  RoomRepositoryImpl(this.roomDataSource);

  @override
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
  }) async {
    try {
      final result = await roomDataSource.getAllRooms(
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
      
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RoomEntity>> getRoomById(int roomId) async {
    try {
      final room = await roomDataSource.getRoomById(roomId);
      return Right(room as RoomEntity);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RoomEntity>> createRoom({
    required String name,
    required int capacity,
    required double price,
    required int areaId,
    String? description,
    List<Map<String, dynamic>>? images,
  }) async {
    try {
      final room = await roomDataSource.createRoom(
        name: name,
        capacity: capacity,
        price: price,
        areaId: areaId,
        description: description,
        images: images,
      );
      return Right(room as RoomEntity);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final room = await roomDataSource.updateRoom(
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
      return Right(room as RoomEntity);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRoom(int roomId) async {
    try {
      await roomDataSource.deleteRoom(roomId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUsersInRoom(int roomId) async {
    return await roomDataSource.getUsersInRoom(roomId);
  }

  @override
  Future<Uint8List> exportUsersInRoom(int roomId) async {
    return await roomDataSource.exportUsersInRoom(roomId);
  }

}
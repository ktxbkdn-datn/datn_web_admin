// lib/src/features/room/domain/usecases/get_all_rooms.dart


import 'package:dartz/dartz.dart';

import '../../../../src/core/error/failures.dart';
import '../entities/room_entity.dart';
import '../repositories/room_repository.dart';

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

// Tương tự cho các use case khác: GetRoomsByArea, CreateRoom, UpdateRoom, DeleteRoom, GetRoomImages, UploadRoomImages, DeleteRoomImage, ReorderRoomImages
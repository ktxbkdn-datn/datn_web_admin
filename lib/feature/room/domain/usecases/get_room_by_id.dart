// lib/src/features/room/domain/usecases/get_room_by_id.dart
import 'package:dartz/dartz.dart';

import '../../../../src/core/error/failures.dart';
import '../entities/room_entity.dart';
import '../repositories/room_repository.dart';

class GetRoomById {
  final RoomRepository repository;

  GetRoomById(this.repository);

  Future<Either<Failure, RoomEntity>> call(int roomId) async {
    return await repository.getRoomById(roomId);
  }
}
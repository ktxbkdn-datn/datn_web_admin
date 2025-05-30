// lib/src/features/room/domain/usecases/delete_room.dart
import 'package:dartz/dartz.dart';

import '../../../../src/core/error/failures.dart';
import '../repositories/room_repository.dart';

class DeleteRoom {
  final RoomRepository repository;

  DeleteRoom(this.repository);

  Future<Either<Failure, void>> call(int roomId) async {
    return await repository.deleteRoom(roomId);
  }
}
// lib/src/features/room/domain/usecases/delete_area.dart
import 'package:dartz/dartz.dart';

import '../../../../../src/core/error/failures.dart';
import '../../repositories/area_repository.dart';


class DeleteArea {
  final AreaRepository repository;

  DeleteArea(this.repository);

  Future<Either<Failure, void>> call(int areaId) async {
    return await repository.deleteArea(areaId);
  }
}
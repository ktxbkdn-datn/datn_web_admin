// lib/src/features/room/domain/usecases/update_area.dart
import 'package:dartz/dartz.dart';
import '../../../../../src/core/error/failures.dart';
import '../../entities/area_entity.dart';
import '../../repositories/area_repository.dart';


class UpdateArea {
  final AreaRepository repository;

  UpdateArea(this.repository);

  Future<Either<Failure, AreaEntity>> call({
    required int areaId,
    String? name,
  }) async {
    return await repository.updateArea(
      areaId: areaId,
      name: name,
    );
  }
}
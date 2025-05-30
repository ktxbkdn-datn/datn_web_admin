// lib/src/features/room/domain/usecases/get_area_by_id.dart
import 'package:dartz/dartz.dart';
import '../../../../../src/core/error/failures.dart';
import '../../entities/area_entity.dart';
import '../../repositories/area_repository.dart';

class GetAreaById {
  final AreaRepository repository;

  GetAreaById(this.repository);

  Future<Either<Failure, AreaEntity>> call(int areaId) async {
    return await repository.getAreaById(areaId);
  }
}
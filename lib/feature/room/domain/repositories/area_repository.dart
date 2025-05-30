// lib/src/features/room/domain/repositories/area_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entities/area_entity.dart';

abstract class AreaRepository {
  Future<Either<Failure, List<AreaEntity>>> getAllAreas({
    required int page,
    required int limit,
  });

  Future<Either<Failure, AreaEntity>> getAreaById(int areaId);

  Future<Either<Failure, AreaEntity>> createArea({
    required String name,
  });

  Future<Either<Failure, AreaEntity>> updateArea({
    required int areaId,
    String? name,
  });

  Future<Either<Failure, void>> deleteArea(int areaId);
}
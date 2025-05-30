// lib/src/features/room/domain/usecases/get_all_areas.dart
import 'package:dartz/dartz.dart';
import '../../../../../src/core/error/failures.dart';
import '../../entities/area_entity.dart';
import '../../repositories/area_repository.dart';


class GetAllAreas {
  final AreaRepository repository;

  GetAllAreas(this.repository);

  Future<Either<Failure, List<AreaEntity>>> call({
    required int page,
    required int limit,
  }) async {
    return await repository.getAllAreas(
      page: page,
      limit: limit,
    );
  }
}
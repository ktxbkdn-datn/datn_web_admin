// lib/src/features/room/domain/usecases/create_area.dart
import 'package:dartz/dartz.dart';
import '../../../../../src/core/error/failures.dart';
import '../../entities/area_entity.dart';
import '../../repositories/area_repository.dart';

class CreateArea {
  final AreaRepository repository;

  CreateArea(this.repository);

  Future<Either<Failure, AreaEntity>> call({
    required String name,
  }) async {
    return await repository.createArea(name: name);
  }
}
// lib/src/features/room/data/repositories/area_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../../domain/entities/area_entity.dart';
import '../../domain/repositories/area_repository.dart';
import '../datasources/area_datasource.dart';
import '../models/area_model.dart';

class AreaRepositoryImpl implements AreaRepository {
  final AreaDataSource dataSource;

  AreaRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<AreaEntity>>> getAllAreas({
    required int page,
    required int limit,
  }) async {
    try {
      final areas = await dataSource.getAllAreas(
        page: page,
        limit: limit,
      );
      return Right(areas as List<AreaEntity>);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AreaEntity>> getAreaById(int areaId) async {
    try {
      final area = await dataSource.getAreaById(areaId);
      return Right(area as AreaEntity);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AreaEntity>> createArea({
    required String name,
  }) async {
    try {
      final area = await dataSource.createArea(
        name: name,
      );
      return Right(area as AreaEntity);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AreaEntity>> updateArea({
    required int areaId,
    String? name,
  }) async {
    try {
      final area = await dataSource.updateArea(
        areaId: areaId,
        name: name,
      );
      return Right(area as AreaEntity);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteArea(int areaId) async {
    try {
      await dataSource.deleteArea(areaId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
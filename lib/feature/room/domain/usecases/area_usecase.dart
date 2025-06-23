import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/feature/room/domain/entities/area_entity.dart';
import 'package:datn_web_admin/feature/room/domain/repositories/area_repository.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';
import 'dart:typed_data';

class CreateArea {
  final AreaRepository repository;

  CreateArea(this.repository);

  Future<Either<Failure, AreaEntity>> call({
    required String name,
  }) async {
    return await repository.createArea(name: name);
  }
}
class DeleteArea {
  final AreaRepository repository;

  DeleteArea(this.repository);

  Future<Either<Failure, void>> call(int areaId) async {
    return await repository.deleteArea(areaId);
  }
}
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
class GetAreaById {
  final AreaRepository repository;

  GetAreaById(this.repository);

  Future<Either<Failure, AreaEntity>> call(int areaId) async {
    return await repository.getAreaById(areaId);
  }
}
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

// Nếu muốn export theo khu vực:
class ExportUsersInArea {
  final AreaRepository repository;

  ExportUsersInArea(this.repository);

  Future<Uint8List> call(int areaId) async {
    return await repository.exportUsersInArea(areaId);
  }
}

// Thêm usecase để lấy danh sách khu vực kèm số lượng sinh viên
class GetAreasWithStudentCount {
  final AreaRepository repository;

  GetAreasWithStudentCount(this.repository);

  Future<List<Map<String, dynamic>>> call() async {
    return await repository.getAreasWithStudentCount();
  }
}

// Thêm usecase để lấy danh sách sinh viên trong khu vực
class GetUsersInArea {
  final AreaRepository repository;

  GetUsersInArea(this.repository);

  Future<List<Map<String, dynamic>>> call(int areaId) async {
    return await repository.getUsersInArea(areaId);
  }
}

// Thêm 2 usecase mới
class GetAllUsersInAllAreas {
  final AreaRepository repository;

  GetAllUsersInAllAreas(this.repository);

  Future<List<Map<String, dynamic>>> call() async {
    return await repository.getAllUsersInAllAreas();
  }
}

class ExportAllUsersInAllAreas {
  final AreaRepository repository;

  ExportAllUsersInAllAreas(this.repository);

  Future<Uint8List> call() async {
    return await repository.exportAllUsersInAllAreas();
  }
}
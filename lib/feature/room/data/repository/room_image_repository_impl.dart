import 'package:dartz/dartz.dart';
import 'dart:io';
import '../../../../src/core/error/failures.dart';
import '../../domain/repositories/room_image_repository.dart';
import '../datasources/room_image_datasource.dart';
import '../models/room_image_model.dart';

class RoomImageRepositoryImpl implements RoomImageRepository {
  final RoomImageDataSource dataSource;

  RoomImageRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getRoomImages(int roomId) async {
    final result = await dataSource.getRoomImages(roomId);
    return result.fold(
          (failure) => Left(failure),
          (images) => Right(images),
    );
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> uploadRoomImages({
    required int roomId,
    required List<Map<String, dynamic>> images,
  }) async {
    try {
      final imageModels = await dataSource.uploadRoomImages(roomId: roomId, images: images);
      // Trả về danh sách ảnh với imageId và imageUrl
      final imageList = imageModels.map((model) => {
        'imageId': model.imageId, // Sửa: Lấy imageId từ model
        'imageUrl': model.imageUrl,
      }).toList();
      return Right(imageList);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteRoomImage({
    required int roomId,
    required int imageId,
  }) async {
    try {
      await dataSource.deleteRoomImage(
        roomId: roomId,
        imageId: imageId,
      );
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteRoomImagesBatch({
    required int roomId,
    required List<int> imageIds,
  }) async {
    try {
      await dataSource.deleteRoomImagesBatch(
        roomId: roomId,
        imageIds: imageIds,
      );
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> reorderRoomImages({
    required int roomId,
    required List<int> imageIds,
  }) async {
    try {
      await dataSource.reorderRoomImages(
        roomId: roomId,
        imageIds: imageIds,
      );
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
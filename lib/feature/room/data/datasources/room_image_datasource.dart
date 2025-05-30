import 'dart:io';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../../../src/core/error/failures.dart';

import '../../../../src/core/network/api_client.dart';
import '../models/room_image_model.dart';

class RoomImageDataSource {
  final ApiService apiService;

  RoomImageDataSource(this.apiService);

  Future<Either<Failure, List<Map<String, dynamic>>>> getRoomImages(int roomId) async {
    try {
      final response = await apiService.get('/rooms/$roomId/images');
      if (response is Map<String, dynamic> && response.containsKey('message')) {
        return Right([]); // Trả về danh sách rỗng nếu không tìm thấy ảnh
      } else if (response is List<dynamic>) {
        // Cast rõ ràng dữ liệu thành List<Map<String, dynamic>>
        final imageList = response.map((item) {
          if (item is Map<String, dynamic>) {
            return {
              'imageId': item['imageId'] as int,
              'imageUrl': item['imageUrl'] as String,
            };
          } else {
            throw Exception('Invalid item format in response: $item');
          }
        }).toList();
        return Right(imageList);
      } else {
        return Left(ServerFailure('Phản hồi API không hợp lệ: $response'));
      }
    } catch (e) {
      if (e is SocketException) {
        return Left(ServerFailure('Không tìm thấy hình ảnh cho phòng $roomId - Lỗi mạng'));
      } else if (e is ServerFailure && e.message.contains('404')) {
        return Right([]); // Trả về danh sách rỗng thay vì lỗi
      }
      return Left(ServerFailure('Lỗi khi gọi API /rooms/$roomId/images: $e'));
    }
  }

  Future<List<RoomImageModel>> uploadRoomImages({
    required int roomId,
    required List<Map<String, dynamic>> images,
  }) async {
    try {
      Map<String, String> fields = {};
      List<http.MultipartFile> files = [];

      if (images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          final bytes = images[i]['bytes'] as Uint8List?;
          final filename = images[i]['name'] as String?;

          if (bytes == null || filename == null) {
            throw Exception('Dữ liệu ảnh không hợp lệ: Thiếu bytes hoặc name');
          }

          final multipartFile = http.MultipartFile.fromBytes(
            'images',
            bytes,
            filename: filename,
          );
          files.add(multipartFile);
          fields['is_primary[$i]'] = (i == 0).toString();
          fields['alt_text[$i]'] = '';
          fields['sort_order[$i]'] = i.toString();
        }
      }

      print('Uploading images to: /admin/rooms/$roomId/images');
      print('Fields: $fields');
      print('Files: ${files.map((f) => f.filename).toList()}');

      final response = await apiService.postMultipart(
        '/admin/rooms/$roomId/images',
        fields: fields,
        files: files,
      );

      print('Upload response: $response');

      if (response is List) {
        return List<RoomImageModel>.generate(
          response.length,
              (index) => RoomImageModel.fromJson(response[index] as Map<String, dynamic>),
        );
      } else if (response is Map<String, dynamic> && response.containsKey('message')) {
        throw Exception('Lỗi từ API: ${response['message']}');
      } else {
        throw Exception('Phản hồi API không hợp lệ, mong đợi một List: $response');
      }
    } catch (e) {
      print('Lỗi khi upload hình ảnh cho phòng $roomId: $e');
      rethrow;
    }
  }

  Future<void> deleteRoomImage({
    required int roomId,
    required int imageId,
  }) async {
    try {
      final response = await apiService.delete('/admin/rooms/$roomId/images/$imageId');
      if (response.isNotEmpty && response['message'] != null && response['message'] != '') {
        throw Exception('Failed to delete room image: ${response['message']}');
      }
    } catch (e) {
      if (e.toString().contains('404') || e.toString().contains('500')) {
        // Nếu ảnh không tồn tại hoặc có lỗi server, coi như xóa thành công
        return;
      }
      rethrow;
    }
  }

  Future<void> deleteRoomImagesBatch({
    required int roomId,
    required List<int> imageIds,
  }) async {
    try {
      final response = await apiService.delete(
        '/admin/rooms/$roomId/images/batch',
        data: {'imageIds': imageIds},
      );
      if (response.isNotEmpty && response['message'] != null && response['message'] != '') {
        throw Exception('Failed to delete room images: ${response['message']}');
      }
    } catch (e) {
      if (e.toString().contains('404') || e.toString().contains('500')) {
        // Nếu ảnh không tồn tại hoặc có lỗi server, coi như xóa thành công
        return;
      }
      rethrow;
    }
  }

  Future<void> reorderRoomImages({
    required int roomId,
    required List<int> imageIds,
  }) async {
    final response = await apiService.post(
      '/admin/rooms/$roomId/images/reorder',
      {'imageIds': imageIds},
    );
    if (response['message'] != 'Sắp xếp lại ảnh thành công') {
      throw Exception('Failed to reorder images: ${response['message']}');
    }
  }
}
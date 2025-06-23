import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../../../../src/core/network/api_client.dart';
import '../../domain/entities/room_entity.dart';
import '../models/room_model.dart';

class RoomDataSource {
  final ApiService apiService;

  RoomDataSource(this.apiService);

  Future<Map<String, dynamic>> getAllRooms({
    required int page,
    required int limit,
    int? minCapacity,
    int? maxCapacity,
    double? minPrice,
    double? maxPrice,
    bool? available,
    String? search,
    int? areaId,
    String? searchUser,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (minCapacity != null) 'min_capacity': minCapacity.toString(),
      if (maxCapacity != null) 'max_capacity': maxCapacity.toString(),
      if (minPrice != null) 'min_price': minPrice.toString(),
      if (maxPrice != null) 'max_price': maxPrice.toString(),
      if (available != null) 'available': available.toString(),
      if (search != null) 'search': search,
      if (areaId != null) 'area_id': areaId.toString(),
      if (searchUser != null && searchUser.isNotEmpty) 'search_user': searchUser,
    };

    final response = await apiService.get('/rooms', queryParams: queryParams);
    print('Phản hồi từ API /rooms: $response');

    // Trả về kết quả dạng map với rooms và totalItems
    List<RoomModel> rooms = [];
    int totalItems = 0;

    if (response is Map<String, dynamic>) {
      // Xử lý các format response khác nhau
      if (response.containsKey('items') && response.containsKey('total')) {
        final items = response['items'];
        totalItems = response['total'];
        
        if (items is List) {
          rooms = items
              .where((item) => item is Map<String, dynamic>)
              .map((json) => RoomModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      } 
      else if (response.containsKey('data') && response.containsKey('total')) {
        final data = response['data'];
        totalItems = response['total'];
        
        if (data is List) {
          rooms = data
              .where((item) => item is Map<String, dynamic>)
              .map((json) => RoomModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      else if (response.containsKey('rooms') && response.containsKey('total')) {
        final roomsData = response['rooms'];
        totalItems = response['total'];
        
        if (roomsData is List) {
          rooms = roomsData
              .where((item) => item is Map<String, dynamic>)
              .map((json) => RoomModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      else {
        throw Exception('Response không có thông tin phân trang');
      }
    } else if (response is List) {
      rooms = response
          .where((item) => item is Map<String, dynamic>)
          .map((json) => RoomModel.fromJson(json as Map<String, dynamic>))
          .toList();
      totalItems = rooms.length;
    } else {
      throw Exception('Unexpected response format');
    }

    return {
      'rooms': rooms,
      'totalItems': totalItems,
    };
  }

  Future<RoomModel> getRoomById(int roomId) async {
    final response = await apiService.get('/rooms/$roomId');
    if (response is Map<String, dynamic>) {
      return RoomModel.fromJson(response);
    }
    if (response is List<dynamic>) {
      throw Exception('Unexpected response format: expected a Map but received a List');
    }
    throw Exception('Unexpected response format: response is not a Map');
  }

  Future<RoomEntity> createRoom({
    required String name,
    required int capacity,
    required double price,
    required int areaId,
    String? description,
    List<Map<String, dynamic>>? images,
  }) async {
    print('Creating room with name: $name, capacity: $capacity, price: $price, areaId: $areaId, description: $description, images: $images');
    final response = await apiService.postMultipart(
      '/admin/rooms',
      fields: {
        'name': name,
        'capacity': capacity.toString(),
        'price': price.toString(),
        'area_id': areaId.toString(),
        if (description != null) 'description': description,
      },
      files: images != null
          ? images
          .asMap()
          .entries
          .map((entry) => http.MultipartFile.fromBytes(
        'images',
        entry.value['bytes'] as List<int>,
        filename: entry.value['name']?.toString() ?? 'image_${entry.key}.jpg',
      ))
          .toList()
          : [],
    );
    print('Create room response: $response');
    return RoomModel.fromJson(response);
  }

  Future<RoomModel> updateRoom({
    required int roomId,
    String? name,
    int? capacity,
    double? price,
    String? description,
    String? status,
    int? areaId,
    List<int>? imageIdsToDelete,
    List<Map<String, dynamic>>? newImages,
  }) async {
    final List<http.MultipartFile> multipartFiles = [];
    if (newImages != null) {
      for (var image in newImages) {
        multipartFiles.add(
          await http.MultipartFile.fromPath(
            'images',
            image['path'],
            filename: image['filename'],
          ),
        );
      }
    }

    final response = await apiService.putMultipart(
      '/admin/rooms/$roomId',
      fields: {
        if (name != null) 'name': name,
        if (capacity != null) 'capacity': capacity.toString(),
        if (price != null) 'price': price.toString(),
        if (description != null) 'description': description,
        if (status != null) 'status': status,
        if (areaId != null) 'area_id': areaId.toString(),
        if (imageIdsToDelete != null) 'image_ids_to_delete': jsonEncode(imageIdsToDelete),
      },
      files: multipartFiles,
    );

    if (response is Map<String, dynamic>) {
      if (response.containsKey('data')) {
        return RoomModel.fromJson(response['data'] as Map<String, dynamic>);
      }
      return RoomModel.fromJson(response);
    }
    throw Exception('Unexpected response format');
  }

  Future<void> deleteRoom(int roomId) async {
    await apiService.delete('/admin/rooms/$roomId');
  }

  Future<List<Map<String, dynamic>>> getUsersInRoom(int roomId) async {
    final response = await apiService.get('/admin/rooms/$roomId/users');
    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    }
    throw Exception('Unexpected response format');
  }

  Future<Uint8List> exportUsersInRoom(int roomId) async {
    return await apiService.getFile('/admin/rooms/$roomId/users/export');
  }

}
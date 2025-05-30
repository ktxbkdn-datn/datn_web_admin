import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../src/core/network/api_client.dart';
import '../../domain/entities/room_entity.dart';
import '../models/room_model.dart';

class RoomDataSource {
  final ApiService apiService;

  RoomDataSource(this.apiService);

  Future<List<RoomModel>> getAllRooms({
    required int page,
    required int limit,
    int? minCapacity,
    int? maxCapacity,
    double? minPrice,
    double? maxPrice,
    bool? available,
    String? search,
    int? areaId,
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
    };

    final response = await apiService.get('/rooms', queryParams: queryParams);
    print('Phản hồi từ API /rooms: $response');

    if (response is List<dynamic>) {
      final responseList = response as List<dynamic>;
      final validItems = responseList.where((item) => item is Map<String, dynamic>).toList();
      return validItems.map((json) => RoomModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    if (response is Map<String, dynamic>) {
      final responseMap = response as Map<String, dynamic>;
      if (responseMap.containsKey('data')) {
        final data = responseMap['data'];
        if (data is List<dynamic>) {
          final dataList = data as List<dynamic>;
          final validItems = dataList.where((item) => item is Map<String, dynamic>).toList();
          return validItems.map((json) => RoomModel.fromJson(json as Map<String, dynamic>)).toList();
        }
        throw Exception('Unexpected response format: "data" is not a List');
      } else if (responseMap.containsKey('rooms')) {
        final rooms = responseMap['rooms'];
        if (rooms is List<dynamic>) {
          final roomsList = rooms as List<dynamic>;
          final validItems = roomsList.where((item) => item is Map<String, dynamic>).toList();
          return validItems.map((json) => RoomModel.fromJson(json as Map<String, dynamic>)).toList();
        }
        throw Exception('Unexpected response format: "rooms" is not a List');
      }
      throw Exception('Unexpected response format: missing "data" or "rooms" key');
    }
    throw Exception('Unexpected response format: response is not a List or Map');
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
}
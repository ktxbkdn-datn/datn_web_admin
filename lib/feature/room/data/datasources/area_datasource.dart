// lib/src/features/room/data/datasources/area_datasource.dart
import 'dart:typed_data';

import '../../../../src/core/network/api_client.dart';
import '../models/area_model.dart';

class AreaDataSource {
  final ApiService apiService;

  AreaDataSource(this.apiService);

  Future<List<AreaModel>> getAllAreas({
    required int page,
    required int limit,
  }) async {
    final queryParameters = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    final response = await apiService.get(
      '/areas',
      queryParams: queryParameters,
    );
    return (response['areas'] as List).map((e) => AreaModel.fromJson(e)).toList();
  }

  Future<AreaModel> getAreaById(int areaId) async {
    final response = await apiService.get('/areas/$areaId');
    return AreaModel.fromJson(response);
  }

  Future<AreaModel> createArea({
    required String name,
  }) async {
    final response = await apiService.post(
      '/admin/areas',
      {'name': name},
    );
    return AreaModel.fromJson(response);
  }

  Future<AreaModel> updateArea({
    required int areaId,
    String? name,
  }) async {
    final response = await apiService.put(
      '/admin/areas/$areaId',
      {'name': name},
    );
    return AreaModel.fromJson(response);
  }

  Future<void> deleteArea(int areaId) async {
    final response = await apiService.delete('/admin/areas/$areaId');
    if (response.isNotEmpty && response['message'] != null && response['message'] != 'Xoá thành công') {
      throw Exception('Failed to delete area: ${response['message']}');
    }
  }

  Future<Uint8List> exportUsersInArea(int areaId) async {
    return await apiService.getFile('/admin/areas/$areaId/users/export');
  }

  Future<List<Map<String, dynamic>>> getAreasWithStudentCount() async {
    final response = await apiService.get('/areas-with-student-count');
    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    }
    throw Exception('Unexpected response format');
  }

  Future<List<Map<String, dynamic>>> getUsersInArea(int areaId) async {
    final response = await apiService.get('/admin/areas/$areaId/users');
    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    }
    throw Exception('Unexpected response format');
  }

  Future<List<Map<String, dynamic>>> getAllUsersInAllAreas() async {
    final response = await apiService.get('/admin/areas/users');
    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    }
    throw Exception('Unexpected response format');
  }

  Future<Uint8List> exportAllUsersInAllAreas() async {
    return await apiService.getFile('/admin/areas/users/export');
  }

  // Sửa phương thức getAreas để hỗ trợ phân trang
  Future<Map<String, dynamic>> getAreas({
    required int page,
    required int limit,
    String? search,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (search != null) 'search': search,
    };

    final response = await apiService.get('/admin/areas', queryParams: queryParams);
    
    List<AreaModel> areas = [];
    int totalAreas = 0;
    
    if (response is Map<String, dynamic>) {
      // Parse response format
      if (response.containsKey('items') && response.containsKey('total')) {
        areas = (response['items'] as List)
            .map((item) => AreaModel.fromJson(item))
            .toList();
        totalAreas = response['total'];
      } 
      else if (response.containsKey('areas') && response.containsKey('total')) {
        areas = (response['areas'] as List)
            .map((item) => AreaModel.fromJson(item))
            .toList();
        totalAreas = response['total'];
      }
      else {
        throw Exception('Unexpected response format');
      }
    } else if (response is List) {
      // Fallback if API doesn't support pagination yet
      areas = response.map((item) => AreaModel.fromJson(item)).toList();
      totalAreas = areas.length;
    } else {
      throw Exception('Unexpected response format');
    }
    
    return {
      'areas': areas,
      'totalAreas': totalAreas,
    };
  }
}
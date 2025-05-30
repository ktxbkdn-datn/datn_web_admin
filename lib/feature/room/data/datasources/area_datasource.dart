// lib/src/features/room/data/datasources/area_datasource.dart
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
}
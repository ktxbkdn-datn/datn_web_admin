// lib/src/features/report/data/datasources/report_type_remote_data_source.dart
import 'dart:io';

import '../../../../src/core/error/failures.dart';
import '../../../../src/core/network/api_client.dart';
import '../models/report_type.dart';


abstract class ReportTypeRemoteDataSource {
  Future<List<ReportTypeModel>> getAllReportTypes({
    int page,
    int limit,
  });

  Future<ReportTypeModel> createReportType(String name);

  Future<ReportTypeModel> updateReportType({
    required int reportTypeId,
    required String name,
  });

  Future<void> deleteReportType(int reportTypeId);
}

class ReportTypeRemoteDataSourceImpl implements ReportTypeRemoteDataSource {
  final ApiService apiService;

  ReportTypeRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<ReportTypeModel>> getAllReportTypes({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      final response = await apiService.get('/report-types', queryParams: queryParams);
      if (response is Map<String, dynamic> && response.containsKey('report_types')) {
        final reportTypes = response['report_types'] as List<dynamic>;
        return reportTypes.map((json) => ReportTypeModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerFailure('Phản hồi API không hợp lệ: $response');
      }
    } catch (e) {
      if (e is SocketException) {
        throw ServerFailure('Không thể kết nối đến server khi lấy danh sách loại báo cáo');
      } else if (e is ServerFailure && e.message.contains('404')) {
        return []; // Trả về danh sách rỗng nếu không tìm thấy
      }
      throw ServerFailure('Lỗi khi lấy danh sách loại báo cáo: $e');
    }
  }

  @override
  Future<ReportTypeModel> createReportType(String name) async {
    try {
      final response = await apiService.post(
        '/admin/report-types',
        {'name': name},
      );
      if (response is Map<String, dynamic>) {
        return ReportTypeModel.fromJson(response);
      } else {
        throw ServerFailure('Phản hồi API không hợp lệ, mong đợi Map: $response');
      }
    } catch (e) {
      if (e is SocketException) {
        throw ServerFailure('Không thể kết nối đến server khi tạo loại báo cáo');
      }
      throw ServerFailure('Lỗi khi tạo loại báo cáo: $e');
    }
  }

  @override
  Future<ReportTypeModel> updateReportType({
    required int reportTypeId,
    required String name,
  }) async {
    try {
      final response = await apiService.put(
        '/admin/report-types/$reportTypeId',
        {'name': name},
      );
      if (response is Map<String, dynamic>) {
        return ReportTypeModel.fromJson(response);
      } else {
        throw ServerFailure('Phản hồi API không hợp lệ, mong đợi Map: $response');
      }
    } catch (e) {
      if (e is SocketException) {
        throw ServerFailure('Không thể kết nối đến server khi cập nhật loại báo cáo');
      }
      throw ServerFailure('Lỗi khi cập nhật loại báo cáo: $e');
    }
  }

  @override
  Future<void> deleteReportType(int reportTypeId) async {
    try {
      final response = await apiService.delete('/admin/report-types/$reportTypeId');
      if (response.isNotEmpty && response['message'] != null && response['message'] != '') {
        throw ServerFailure('Không thể xóa loại báo cáo: ${response['message']}');
      }
    } catch (e) {
      if (e.toString().contains('404') || e.toString().contains('500')) {
        // Nếu loại báo cáo không tồn tại hoặc có lỗi server, coi như xóa thành công
        return;
      }
      if (e is SocketException) {
        throw ServerFailure('Không thể kết nối đến server khi xóa loại báo cáo');
      }
      throw ServerFailure('Lỗi khi xóa loại báo cáo: $e');
    }
  }
}
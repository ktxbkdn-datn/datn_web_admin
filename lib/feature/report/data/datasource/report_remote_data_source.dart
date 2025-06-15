import 'dart:io';
import '../../../../src/core/error/failures.dart';
import '../../../../src/core/network/api_client.dart';
import '../models/report_model.dart';

abstract class ReportRemoteDataSource {
  Future<(List<ReportModel>, int)> getAllReports({
    int page,
    int limit,
    int? userId,
    int? roomId,
    String? status,
    int? reportTypeId,
    String? searchQuery,
  });

  Future<ReportModel> getReportById(int reportId);

  Future<ReportModel> updateReport({
    required int reportId,
    required int roomId,
    required int reportTypeId,
    required String description,
    required String status,
  });

  Future<ReportModel> updateReportStatus({
    required int reportId,
    required String status,
  });

  Future<void> deleteReport(int reportId);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final ApiService apiService;

  ReportRemoteDataSourceImpl(this.apiService);

  @override
  Future<(List<ReportModel>, int)> getAllReports({
    int page = 1,
    int limit = 10,
    int? userId,
    int? roomId,
    String? status,
    int? reportTypeId,
    String? searchQuery,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (userId != null) 'user_id': userId.toString(),
        if (roomId != null) 'room_id': roomId.toString(),
        if (status != null) 'status': status,
        if (reportTypeId != null) 'report_type_id': reportTypeId.toString(), // QUAN TRỌNG
        if (searchQuery != null) 'search': searchQuery,
      };
      print('Calling API GET /admin/reports with params: $queryParams');
      final response = await apiService.get('/admin/reports', queryParams: queryParams);
      print('getAllReports raw response: $response');
      if (response is Map<String, dynamic> && response.containsKey('reports') && response.containsKey('total')) {
        final reports = response['reports'] as List<dynamic>;
        final totalItems = response['total'] as int? ?? 0;
        final result = reports.map((json) => ReportModel.fromJson(json as Map<String, dynamic>)).toList();
        print('getAllReports parsed data: ${result.map((report) => report.toJson()).toList()}, total: $totalItems');
        return (result, totalItems);
      } else {
        throw ServerFailure('Phản hồi API không hợp lệ: $response');
      }
    } catch (e) {
      print('Error in getAllReports: $e');
      if (e is SocketException) {
        throw ServerFailure('Không thể kết nối đến server khi lấy danh sách báo cáo');
      } else if (e is ServerFailure && e.message.contains('404')) {
        return (<ReportModel>[], 0); // Trả về danh sách rỗng nếu không tìm thấy
      }
      throw ServerFailure('Lỗi khi lấy danh sách báo cáo: $e');
    }
  }

  @override
  Future<ReportModel> getReportById(int reportId) async {
    try {
      print('Calling API GET /reports/$reportId');
      final response = await apiService.get('/reports/$reportId');
      print('getReportById raw response for report $reportId: $response');
      if (response is Map<String, dynamic>) {
        final report = ReportModel.fromJson(response);
        print('getReportById parsed data for report $reportId: ${report.toJson()}');
        return report;
      } else {
        throw ServerFailure('Phản hồi API không hợp lệ, mong đợi Map: $response');
      }
    } catch (e) {
      print('Error in getReportById for report $reportId: $e');
      if (e is SocketException) {
        throw ServerFailure('Không thể kết nối đến server khi lấy chi tiết báo cáo');
      }
      throw ServerFailure('Lỗi khi lấy chi tiết báo cáo: $e');
    }
  }

  @override
  Future<ReportModel> updateReport({
    required int reportId,
    required int roomId,
    required int reportTypeId,
    required String description,
    required String status,
  }) async {
    try {
      final body = {
        'room_id': roomId,
        'report_type_id': reportTypeId,
        'content': description,
        'status': status,
      };
      print('Calling API PUT /admin/reports/$reportId with body: $body');
      final response = await apiService.put(
        '/admin/reports/$reportId',
        body,
      );
      print('updateReport raw response for report $reportId: $response');
      if (response is Map<String, dynamic>) {
        final report = ReportModel.fromJson(response);
        print('updateReport parsed data for report $reportId: ${report.toJson()}');
        return report;
      } else {
        throw ServerFailure('Phản hồi API không hợp lệ, mong đợi Map: $response');
      }
    } catch (e) {
      print('Error in updateReport for report $reportId: $e');
      if (e is SocketException) {
        throw ServerFailure('Không thể kết nối đến server khi cập nhật báo cáo');
      }
      throw ServerFailure('Lỗi khi cập nhật báo cáo: $e');
    }
  }

  @override
  Future<ReportModel> updateReportStatus({
    required int reportId,
    required String status,
  }) async {
    try {
      final body = {'status': status};
      print('Calling API PUT /admin/reports/$reportId/status with body: $body');
      final response = await apiService.put(
        '/admin/reports/$reportId/status',
        body,
      );
      print('updateReportStatus raw response for report $reportId: $response');
      if (response is Map<String, dynamic>) {
        final report = ReportModel.fromJson(response);
        print('updateReportStatus parsed data for report $reportId: ${report.toJson()}');
        return report;
      } else {
        throw ServerFailure('Phản hồi API không hợp lệ, mong đợi Map: $response');
      }
    } catch (e) {
      print('Error in updateReportStatus for report $reportId: $e');
      if (e is SocketException) {
        throw ServerFailure('Không thể kết nối đến server khi cập nhật trạng thái báo cáo');
      }
      throw ServerFailure('Lỗi khi cập nhật trạng thái báo cáo: $e');
    }
  }

  @override
  Future<void> deleteReport(int reportId) async {
    try {
      print('Calling API DELETE /admin/reports/$reportId');
      final response = await apiService.delete('/admin/reports/$reportId');
      print('deleteReport raw response for report $reportId: $response');
      if (response.isNotEmpty && response['message'] != null && response['message'] != '') {
        throw ServerFailure('Không thể xóa báo cáo: ${response['message']}');
      }
    } catch (e) {
      print('Error in deleteReport for report $reportId: $e');
      if (e.toString().contains('404') || e.toString().contains('500')) {
        // Nếu báo cáo không tồn tại hoặc có lỗi server, coi như xóa thành công
        return;
      }
      if (e is SocketException) {
        throw ServerFailure('Không thể kết nối đến server khi xóa báo cáo');
      }
      throw ServerFailure('Lỗi khi xóa báo cáo: $e');
    }
  }
}
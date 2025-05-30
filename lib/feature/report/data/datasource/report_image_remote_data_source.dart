// lib/src/features/report/data/datasources/report_image_remote_data_source.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../src/core/error/failures.dart';
import '../../../../src/core/network/api_client.dart';
import '../models/report_image_model.dart';

abstract class ReportImageRemoteDataSource {
  Future<List<ReportImageModel>> getReportImages(int reportId);
  Future<void> deleteReportImage({
    required int reportId,
    required int imageId,
  });
}

class ReportImageRemoteDataSourceImpl implements ReportImageRemoteDataSource {
  final ApiService apiService;

  ReportImageRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<ReportImageModel>> getReportImages(int reportId) async {
    try {
      final response = await apiService.get('/reports/$reportId/images');
      if (response is Map<String, dynamic> && response.containsKey('message')) {
        return []; // Trả về danh sách rỗng nếu không tìm thấy ảnh
      } else if (response is List<dynamic>) {
        final imageList = response
            .map((item) => ReportImageModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return imageList;
      } else {
        throw ServerFailure('Phản hồi API không hợp lệ: $response');
      }
    } catch (e) {
      if (e is SocketException) {
        throw ServerFailure('Không tìm thấy hình ảnh cho báo cáo $reportId - Lỗi mạng');
      } else if (e is ServerFailure && e.message.contains('404')) {
        return []; // Trả về danh sách rỗng thay vì lỗi
      }
      throw ServerFailure('Lỗi khi gọi API /reports/$reportId/images: $e');
    }
  }

  @override
  Future<void> deleteReportImage({
    required int reportId,
    required int imageId,
  }) async {
    try {
      final response = await apiService.delete('/admin/reports/$reportId/images/$imageId');
      if (response.isNotEmpty && response['message'] != null && response['message'] != '') {
        throw ServerFailure('Không thể xóa hình ảnh: ${response['message']}');
      }
    } catch (e) {
      if (e.toString().contains('404') || e.toString().contains('500')) {
        // Nếu ảnh không tồn tại hoặc có lỗi server, coi như xóa thành công
        return;
      }
      throw ServerFailure('Lỗi khi xóa hình ảnh cho báo cáo $reportId: $e');
    }
  }
}
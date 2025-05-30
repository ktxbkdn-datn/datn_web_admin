import 'package:datn_web_admin/feature/admin/data/models/admin_model.dart';
import 'package:datn_web_admin/feature/admin/domain/entities/admin_entity.dart';
import '../../../../src/core/error/failures.dart';
import '../../../../src/core/network/api_client.dart';


class AdminDataSource {
  final ApiService apiService;

  AdminDataSource(this.apiService);

  Future<List<AdminEntity>> getAllAdmins({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await apiService.get(
        '/admin/admins',
        queryParams: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );
      if (response.containsKey('admins')) {
        final admins = (response['admins'] as List<dynamic>)
            .map((json) => AdminModel.fromJson(json as Map<String, dynamic>))
            .map((model) => AdminEntity(
          adminId: model.adminId,
          username: model.username,
          fullName: model.fullName,
          email: model.email,
          phone: model.phone,
          createdAt: model.createdAt,
          resetToken: model.resetToken,
          resetTokenExpiry: model.resetTokenExpiry,
          resetAttempts: model.resetAttempts,
        ))
            .toList();
        return admins;
      }
      throw ServerFailure(response['message'] ?? 'Lỗi lấy danh sách admin');
    } catch (e) {
      if (e is ServerFailure) {
        throw e;
      }
      throw ServerFailure('Lỗi lấy danh sách admin: $e');
    }
  }

  Future<AdminEntity> getAdminById(int adminId) async {
    print('Fetching admin with ID: $adminId');
    try {
      final response = await apiService.get('/admin/admins/$adminId');
      print('Response from GET /admin/admins/$adminId: $response');
      if (response.containsKey('admin_id')) {
        final model = AdminModel.fromJson(response);
        return AdminEntity(
          adminId: model.adminId,
          username: model.username,
          fullName: model.fullName,
          email: model.email,
          phone: model.phone,
          createdAt: model.createdAt,
          resetToken: model.resetToken,
          resetTokenExpiry: model.resetTokenExpiry,
          resetAttempts: model.resetAttempts,
        );
      }
      throw ServerFailure(response['message'] ?? 'Lỗi lấy thông tin admin');
    } catch (e) {
      if (e is ServerFailure) {
        throw e;
      }
      print('Error in getAdminById: $e');
      throw ServerFailure('Lỗi lấy thông tin admin: $e');
    }
  }

  Future<AdminEntity> createAdmin({
    required String username,
    required String password,
    required String email,
    String? fullName,
    String? phone,
  }) async {
    try {
      final response = await apiService.post(
        '/admin/admins',
        {
          'username': username,
          'password': password,
          'email': email,
          'full_name': fullName,
          'phone': phone,
        },
      );
      if (response.containsKey('admin_id')) {
        final model = AdminModel.fromJson(response);
        return AdminEntity(
          adminId: model.adminId,
          username: model.username,
          fullName: model.fullName,
          email: model.email,
          phone: model.phone,
          createdAt: model.createdAt,
          resetToken: model.resetToken,
          resetTokenExpiry: model.resetTokenExpiry,
          resetAttempts: model.resetAttempts,
        );
      }
      throw ServerFailure(response['message'] ?? 'Lỗi tạo admin');
    } catch (e) {
      if (e is ServerFailure) {
        throw e;
      }
      throw ServerFailure('Lỗi tạo admin: $e');
    }
  }

  Future<AdminEntity> updateAdmin({
    required int adminId,
    String? fullName,
    String? email,
    String? phone,
  }) async {
    try {
      final response = await apiService.put(
        '/admin/admins/$adminId',
        {
          if (fullName != null) 'full_name': fullName,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
        },
      );
      if (response.containsKey('admin_id')) {
        final model = AdminModel.fromJson(response);
        return AdminEntity(
          adminId: model.adminId,
          username: model.username,
          fullName: model.fullName,
          email: model.email,
          phone: model.phone,
          createdAt: model.createdAt,
          resetToken: model.resetToken,
          resetTokenExpiry: model.resetTokenExpiry,
          resetAttempts: model.resetAttempts,
        );
      }
      throw ServerFailure(response['message'] ?? 'Lỗi cập nhật admin');
    } catch (e) {
      if (e is ServerFailure) {
        throw e;
      }
      throw ServerFailure('Lỗi cập nhật admin: $e');
    }
  }

  Future<void> deleteAdmin(int adminId) async {
    try {
      final response = await apiService.delete('/admin/admins/$adminId');
      return;
    } catch (e) {
      if (e is ServerFailure) {
        throw e;
      }
      throw ServerFailure('Lỗi xóa admin: $e');
    }
  }

  Future<void> requestPasswordReset({
    required String email,
  }) async {
    try {
      final response = await apiService.post(
        '/admin/reset-password/request',
        {
          'email': email,
        },
      );
      if (response.containsKey('message')) {
        return;
      }
      throw ServerFailure(response['message'] ?? 'Lỗi gửi mã xác nhận');
    } catch (e) {
      if (e is ServerFailure) {
        throw e;
      }
      throw ServerFailure('Lỗi gửi mã xác nhận: $e');
    }
  }

  Future<void> confirmResetPassword({
    required String email,
    required String newPassword,
    required String code,
  }) async {
    try {
      final response = await apiService.post(
        '/admin/reset-password',
        {
          'email': email,
          'newPassword': newPassword,
          'code': code,
        },
      );
      if (response.containsKey('message')) {
        return;
      }
      throw ServerFailure(response['message'] ?? 'Lỗi đặt lại mật khẩu');
    } catch (e) {
      if (e is ServerFailure) {
        throw e;
      }
      throw ServerFailure('Lỗi đặt lại mật khẩu: $e');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await apiService.put(
        '/admin/password',
        {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      if (response.containsKey('message')) {
        return;
      }
      throw ServerFailure(response['message'] ?? 'Lỗi đổi mật khẩu');
    } catch (e) {
      if (e is ServerFailure) {
        throw e;
      }
      throw ServerFailure('Lỗi đổi mật khẩu: $e');
    }
  }
}
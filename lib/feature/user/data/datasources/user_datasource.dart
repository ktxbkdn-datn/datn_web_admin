import 'package:datn_web_admin/feature/user/domain/entities/user_entity.dart';
import '../../../../src/core/error/failures.dart';
import '../../../../src/core/network/api_client.dart';
import '../model/user_model.dart';

class UserDataSource {
  final ApiService apiService;

  UserDataSource(this.apiService);

  Future<(List<UserModel>, int)> getAllUsers({
    int page = 1,
    int limit = 10,
    String? keyword, 
    String? email,
    String? fullname,
    String? phone,
    String? className,
  }) async {
    try {
      final response = await apiService.get(
        '/users',
        queryParams: {
          'page': page.toString(),
          'limit': limit.toString(),
          if (keyword != null && keyword.isNotEmpty) 'keyword': keyword, 
          if (email != null) 'email': email,
          if (fullname != null) 'fullname': fullname,
          if (phone != null) 'phone': phone,
          if (className != null) 'class_name': className,
        },
      );
      if (response.containsKey('users')) {
        final usersJson = response['users'] as List<dynamic>? ?? [];
        final totalItems = (response['total'] as int?) ?? 0;
        final users = usersJson
            .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return (users, totalItems);
      }
      throw ServerFailure(response['message'] ?? 'Lỗi lấy danh sách người dùng');
    } catch (e) {
      if (e is ServerFailure) {
        throw e;
      }
      throw ServerFailure('Lỗi lấy danh sách người dùng: $e');
    }
  }

  Future<UserModel> getUserById(int userId) async {
    try {
      final response = await apiService.get('/users/$userId');
      if (response.containsKey('user_id')) {
        return UserModel.fromJson(response);
      }
      throw ServerFailure(response['message'] ?? 'Lỗi lấy thông tin người dùng');
    } catch (e) {
      if (e is ServerFailure) {
        throw e;
      }
      throw ServerFailure('Lỗi lấy thông tin người dùng: $e');
    }
  }

  Future<UserModel> createUser({
    required String email,
    required String fullname,
    String? phone,
  }) async {
    try {
      final response = await apiService.post(
        '/admin/users',
        {
          'email': email,
          'fullname': fullname,
          'phone': phone,
        },
      );
      if (response.containsKey('user') && response['user'].containsKey('user_id')) {
        return UserModel.fromJson(response['user']);
      }
      throw ServerFailure(response['message'] ?? 'Lỗi tạo người dùng');
    } catch (e) {
      if (e is ServerFailure) {
        throw e;
      }
      throw ServerFailure('Lỗi tạo người dùng: $e');
    }
  }

  Future<UserModel> updateUser({
    required int userId,
    String? fullname,
    String? email,
    String? phone,
    String? cccd,
    DateTime? dateOfBirth,
    String? className,
  }) async {
    try {
      final response = await apiService.put(
        '/admin/users/$userId',
        {
          if (fullname != null) 'fullname': fullname,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
          if (cccd != null) 'CCCD': cccd,
          if (dateOfBirth != null) 'date_of_birth': dateOfBirth.toIso8601String(),
          if (className != null) 'class_name': className,
        },
      );
      if (response.containsKey('user_id')) {
        return UserModel.fromJson(response);
      }
      throw ServerFailure(response['message'] ?? 'Lỗi cập nhật người dùng');
    } catch (e) {
      if (e is ServerFailure) {
        throw e;
      }
      throw ServerFailure('Lỗi cập nhật người dùng: $e');
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      await apiService.delete('/admin/users/$userId');
    } catch (e) {
      if (e is ServerFailure) {
        throw e;
      }
      throw ServerFailure('Lỗi xóa người dùng: $e');
    }
  }
}
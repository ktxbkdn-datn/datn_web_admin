// lib/src/features/user/data/datasources/user_datasource.dart

import 'package:datn_web_admin/feature/user/domain/entities/user_entity.dart';

import '../../../../src/core/error/failures.dart';
import '../../../../src/core/network/api_client.dart';

import '../model/user_model.dart';

class UserDataSource {
  final ApiService apiService;

  UserDataSource(this.apiService);

  Future<List<UserEntity>> getAllUsers({
    int page = 1,
    int limit = 10,
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
          if (email != null) 'email': email,
          if (fullname != null) 'fullname': fullname,
          if (phone != null) 'phone': phone,
          if (className != null) 'class_name': className,
        },
      );
      if (response.containsKey('users')) {
        final users = (response['users'] as List<dynamic>)
            .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
            .map((model) => model.toEntity())
            .toList();
        return users;
      }
      throw ServerFailure(response['message'] ?? 'Lỗi lấy danh sách người dùng');
    } catch (e) {
      if (e is ServerFailure) {
        throw e;
      }
      throw ServerFailure('Lỗi lấy danh sách người dùng: $e');
    }
  }

  Future<UserEntity> getUserById(int userId) async {
    try {
      final response = await apiService.get('/users/$userId');
      if (response.containsKey('user_id')) {
        final model = UserModel.fromJson(response);
        return model.toEntity();
      }
      throw ServerFailure(response['message'] ?? 'Lỗi lấy thông tin người dùng');
    } catch (e) {
      if (e is ServerFailure) {
        throw e;
      }
      throw ServerFailure('Lỗi lấy thông tin người dùng: $e');
    }
  }

  Future<UserEntity> createUser({
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
        final model = UserModel.fromJson(response['user']);
        return model.toEntity();
      }
      throw ServerFailure(response['message'] ?? 'Lỗi tạo người dùng');
    } catch (e) {
      if (e is ServerFailure) {
        throw e;
      }
      throw ServerFailure('Lỗi tạo người dùng: $e');
    }
  }

  Future<UserEntity> updateUser({
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
        final model = UserModel.fromJson(response);
        return model.toEntity();
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
      // Không cần xử lý dữ liệu trả về vì DELETE không cần dữ liệu
    } catch (e) {
      if (e is ServerFailure) {
        throw e;
      }
      throw ServerFailure('Lỗi xóa người dùng: $e');
    }
  }
}
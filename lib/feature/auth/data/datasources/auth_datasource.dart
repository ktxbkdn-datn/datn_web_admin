import 'package:datn_web_admin/src/core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../src/core/error/failures.dart';
import '../models/auth_model.dart';

class AuthDataSource {
  final ApiService apiService;

  AuthDataSource(this.apiService);

  Future<AuthModel> adminLogin(String username, String password, bool rememberMe) async {
    try {
      final response = await apiService.post(
        '/auth/admin/login',
        {
          'username': username,
          'password': password,
          'remember_me': rememberMe,
        },
      );
      print('API response: $response');
      if (!response.containsKey('access_token') || !response.containsKey('refresh_token')) {
        throw ServerFailure('Phản hồi đăng nhập thiếu access_token hoặc refresh_token');
      }
      final authModel = AuthModel.fromJson(response);
      
      await apiService.setToken(
        authModel.accessToken,
        refreshToken: authModel.refreshToken,
        rememberMe: rememberMe,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', rememberMe);
      if (rememberMe) {
        await prefs.setString('saved_username', username);
        await prefs.setString('saved_password', password);
        print('Saved username and password for rememberMe: true');
      } else {
        await prefs.remove('saved_username');
        await prefs.remove('saved_password');
        print('Removed username and password for rememberMe: false');
      }

      return authModel;
    } on ServerFailure catch (e) {
      throw ServerFailure(e.message);
    } on NetworkFailure catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure('Lỗi đăng nhập: $e');
    }
  }

  Future<void> logout(String token) async {
    try {
      final effectiveToken = token.isEmpty ? apiService.token ?? '' : token;
      if (effectiveToken.isEmpty) {
        throw ServerFailure('Token không tồn tại để đăng xuất');
      }
      await apiService.post(
        '/auth/logout',
        {},
        headers: {'Authorization': 'Bearer $effectiveToken'},
      );
      await apiService.clearToken(); // clearToken đã xử lý logic "Remember Me"
    } on ServerFailure catch (e) {
      throw ServerFailure(e.message);
    } on NetworkFailure catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure('Lỗi đăng xuất: $e');
    }
  }

  Future<void> forgotPassword(String email) async {
    await apiService.post(
      '/auth/forgot-password',
      {'email': email},
    );
  }

  Future<void> resetPassword(String email, String newPassword, String code) async {
    await apiService.post(
      '/auth/reset-password',
      {
        'email': email,
        'newPassword': newPassword,
        'code': code,
      },
    );
  }
}
import 'package:dartz/dartz.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../../src/core/error/failures.dart';
import '../datasources/auth_datasource.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, AuthEntity>> adminLogin(String username, String password, {bool rememberMe = false}) async {
    try {
      final authModel = await dataSource.adminLogin(username, password, rememberMe);
      await dataSource.apiService.setToken(authModel.accessToken, refreshToken: authModel.refreshToken, rememberMe: rememberMe);
      final decodedToken = JwtDecoder.decode(authModel.accessToken);
      final userId = decodedToken['sub'] as String?;
      final type = decodedToken['type'] as String? ?? 'UNKNOWN';
      if (userId == null) {
        return Left(ServerFailure('Không thể trích xuất ID từ token'));
      }
      return Right(AuthEntity(
        id: int.parse(userId),
        accessToken: authModel.accessToken,
        refreshToken: authModel.refreshToken ?? '',
        type: type,
      ));
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkFailure catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi đăng nhập: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout(String token) async {
    try {
      await dataSource.logout(token);
      await dataSource.apiService.clearToken();
      return const Right(null);
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkFailure catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi đăng xuất: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await dataSource.forgotPassword(email);
      return const Right(null);
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkFailure catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi gửi yêu cầu quên mật khẩu: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email, String newPassword, String code) async {
    try {
      await dataSource.resetPassword(email, newPassword, code);
      return const Right(null);
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkFailure catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi đặt lại mật khẩu: $e'));
    }
  }

  @override
  Future<String?> getUserId() async {
    try {
      return await dataSource.apiService.getUserIdFromToken();
    } catch (e) {
      print('Error getting user ID from token: $e');
      return null;
    }
  }
}
import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> adminLogin(String username, String password, {bool rememberMe});
  Future<Either<Failure, void>> logout(String token);
  Future<Either<Failure, void>> forgotPassword(String email);
  Future<Either<Failure, void>> resetPassword(String email, String newPassword, String code);
}
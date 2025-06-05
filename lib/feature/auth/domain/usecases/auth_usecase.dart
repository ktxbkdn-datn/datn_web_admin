import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class ForgotPassword {
  final AuthRepository repository;

  ForgotPassword(this.repository);

  Future<Either<Failure, void>> call(String email) async {
    return await repository.forgotPassword(email);
  }
}

class Login {
  final AuthRepository repository;

  Login(this.repository);

  Future<Either<Failure, AuthEntity>> adminLogin(String username, String password, {bool rememberMe = false}) async {
    return await repository.adminLogin(username, password, rememberMe: rememberMe);
  }
}

class Logout {
  final AuthRepository repository;

  Logout(this.repository);

  Future<Either<Failure, void>> call(String token) async {
    return await repository.logout(token);
  }
}

class ResetPassword {
  final AuthRepository repository;

  ResetPassword(this.repository);

  Future<Either<Failure, void>> call(String email, String newPassword, String code) async {
    return await repository.resetPassword(email, newPassword, code);
  }
}
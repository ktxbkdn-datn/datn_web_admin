// lib/src/features/auth/domain/repositories/auth_repository.dart

import '../../../../src/core/error/failures.dart';
import '../../../../src/core/network/api_client.dart';
import '../../../admin/domain/entities/admin_entity.dart';
import '../entities/auth_entity.dart';
import 'package:dartz/dartz.dart';
abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> adminLogin(String username, String password);
  Future<Either<Failure, void>> logout(String token);
  Future<Either<Failure, void>> forgotPassword(String email);
  Future<Either<Failure, void>> resetPassword(
      String email, String newPassword, String code);
}

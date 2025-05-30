// lib/src/features/admin/domain/repositories/admin_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entities/admin_entity.dart';

abstract class AdminRepository {
  Future<Either<Failure, List<AdminEntity>>> getAllAdmins({
    int page,
    int limit,
  });

  Future<Either<Failure, AdminEntity>> getAdminById(int adminId);

  Future<Either<Failure, AdminEntity>> createAdmin({
    required String username,
    required String password,
    required String email,
    String? fullName,
    String? phone,
  });

  Future<Either<Failure, AdminEntity>> updateAdmin({
    required int adminId,
    String? fullName,
    String? email,
    String? phone,
  });

  Future<Either<Failure, void>> deleteAdmin(int adminId);

  Future<Either<Failure, void>> requestPasswordReset({
    required String email,
  });

  Future<Either<Failure, void>> confirmResetPassword({
    required String email,
    required String newPassword,
    required String code,
  });

  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
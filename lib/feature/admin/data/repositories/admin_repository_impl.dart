// lib/src/features/admin/data/repositories/admin_repository_impl.dart
import 'package:dartz/dartz.dart';

import 'package:datn_web_admin/feature/admin/data/datasources/admin_datasource.dart';
import 'package:datn_web_admin/feature/admin/domain/entities/admin_entity.dart';
import 'package:datn_web_admin/feature/admin/domain/repositories/admin_repository.dart';

import '../../../../src/core/error/failures.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminDataSource dataSource;

  AdminRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<AdminEntity>>> getAllAdmins({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final admins = await dataSource.getAllAdmins(page: page, limit: limit);
      return Right(admins);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminEntity>> getAdminById(int adminId) async {
    try {
      final admin = await dataSource.getAdminById(adminId);
      return Right(admin);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminEntity>> createAdmin({
    required String username,
    required String password,
    required String email,
    String? fullName,
    String? phone,
  }) async {
    try {
      final admin = await dataSource.createAdmin(
        username: username,
        password: password,
        email: email,
        fullName: fullName,
        phone: phone,
      );
      return Right(admin);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminEntity>> updateAdmin({
    required int adminId,
    String? fullName,
    String? email,
    String? phone,
  }) async {
    try {
      final admin = await dataSource.updateAdmin(
        adminId: adminId,
        fullName: fullName,
        email: email,
        phone: phone,
      );
      return Right(admin);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAdmin(int adminId) async {
    try {
      await dataSource.deleteAdmin(adminId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({required String currentPassword, required String newPassword}) async {
    try {
      await dataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> confirmResetPassword({required String email, required String newPassword, required String code}) async {
    try {
      await dataSource.confirmResetPassword(
        email: email,
        newPassword: newPassword,
        code: code,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> requestPasswordReset({required String email}) async {
    try {
      await dataSource.requestPasswordReset(email: email);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
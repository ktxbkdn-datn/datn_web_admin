// lib/src/features/admin/domain/usecases/create_admin.dart
import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entities/admin_entity.dart';
import '../repositories/admin_repository.dart';

class CreateAdmin {
  final AdminRepository repository;

  CreateAdmin(this.repository);

  Future<Either<Failure, AdminEntity>> call({
    required String username,
    required String password,
    required String email,
    String? fullName,
    String? phone,
  }) async {
    return await repository.createAdmin(
      username: username,
      password: password,
      email: email,
      fullName: fullName,
      phone: phone,
    );
  }
}
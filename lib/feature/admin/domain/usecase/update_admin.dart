// lib/src/features/admin/domain/usecases/update_admin.dart
import 'package:dartz/dartz.dart';

import '../../../../src/core/error/failures.dart';
import '../entities/admin_entity.dart';
import '../repositories/admin_repository.dart';

class UpdateAdmin {
  final AdminRepository repository;

  UpdateAdmin(this.repository);

  Future<Either<Failure, AdminEntity>> call({
    required int adminId,
    String? fullName,
    String? email,
    String? phone,
  }) async {
    return await repository.updateAdmin(
      adminId: adminId,
      fullName: fullName,
      email: email,
      phone: phone,
    );
  }
}
// lib/src/features/admin/domain/usecases/delete_admin.dart
import 'package:dartz/dartz.dart';

import '../../../../src/core/error/failures.dart';
import '../repositories/admin_repository.dart';

class DeleteAdmin {
  final AdminRepository repository;

  DeleteAdmin(this.repository);

  Future<Either<Failure, void>> call(int adminId) async {
    return await repository.deleteAdmin(adminId);
  }
}
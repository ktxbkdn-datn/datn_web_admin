// lib/src/features/admin/domain/usecases/change_password.dart
import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../repositories/admin_repository.dart';

class ChangePassword {
  final AdminRepository repository;

  ChangePassword(this.repository);

  Future<Either<Failure, void>> call({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
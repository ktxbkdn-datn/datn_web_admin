// lib/src/features/admin/domain/usecases/confirm_reset_password.dart
import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../repositories/admin_repository.dart';

class ConfirmResetPassword {
  final AdminRepository repository;

  ConfirmResetPassword(this.repository);

  Future<Either<Failure, void>> call({
    required String email,
    required String newPassword,
    required String code,
  }) async {
    return await repository.confirmResetPassword(
      email: email,
      newPassword: newPassword,
      code: code,
    );
  }
}
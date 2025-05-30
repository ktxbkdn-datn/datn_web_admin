// lib/src/features/admin/domain/usecases/request_password_reset.dart
import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../repositories/admin_repository.dart';

class RequestPasswordReset {
  final AdminRepository repository;

  RequestPasswordReset(this.repository);

  Future<Either<Failure, void>> call({
    required String email,
  }) async {
    return await repository.requestPasswordReset(email: email);
  }
}
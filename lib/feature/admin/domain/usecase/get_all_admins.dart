// lib/src/features/admin/domain/usecases/get_all_admins.dart
import 'package:dartz/dartz.dart';

import '../../../../src/core/error/failures.dart';
import '../entities/admin_entity.dart';
import '../repositories/admin_repository.dart';

class GetAllAdmins {
  final AdminRepository repository;

  GetAllAdmins(this.repository);

  Future<Either<Failure, List<AdminEntity>>> call({
    int page = 1,
    int limit = 10,
  }) async {
    return await repository.getAllAdmins(page: page, limit: limit);
  }
}
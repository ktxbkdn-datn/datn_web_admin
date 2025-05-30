// lib/src/features/admin/domain/usecases/get_admin_by_id.dart
import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entities/admin_entity.dart';
import '../repositories/admin_repository.dart';

class GetAdminById {
  final AdminRepository repository;

  GetAdminById(this.repository);

  Future<Either<Failure, AdminEntity>> call(int adminId) async {
    try {
      print('Calling GetAdminById for admin ID: $adminId');
      final result = await repository.getAdminById(adminId);
      return result.fold(
            (failure) {
          print('GetAdminById failed for admin ID: $adminId, failure: ${failure.message}');
          return Left(failure);
        },
            (admin) {
          print('GetAdminById successful for admin ID: $adminId');
          return Right(admin);
        },
      );
    } catch (e) {
      print('Unexpected error in GetAdminById: $e');
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }
}
// lib/src/features/user/domain/usecases/delete_user.dart
import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../repositories/user_repository.dart';

class DeleteUser {
  final UserRepository repository;

  DeleteUser(this.repository);

  Future<Either<Failure, void>> call(int userId) async {
    try {
      print('Calling DeleteUser for user ID: $userId');
      final result = await repository.deleteUser(userId);
      return result.fold(
            (failure) {
          print('DeleteUser failed: ${failure.message}');
          return Left(failure);
        },
            (_) {
          print('DeleteUser successful for user ID: $userId');
          return const Right(null);
        },
      );
    } catch (e) {
      print('Unexpected error in DeleteUser: $e');
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }
}
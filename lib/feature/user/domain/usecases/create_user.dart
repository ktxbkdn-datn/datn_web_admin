// lib/src/features/user/domain/usecases/create_user.dart
import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class CreateUser {
  final UserRepository repository;

  CreateUser(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String fullname,
    String? phone,
  }) async {
    try {
      print('Calling CreateUser with email: $email');
      final result = await repository.createUser(
        email: email,
        fullname: fullname,
        phone: phone,
      );
      return result.fold(
            (failure) {
          print('CreateUser failed: ${failure.message}');
          return Left(failure);
        },
            (user) {
          print('CreateUser successful, created user ID: ${user.userId}');
          return Right(user);
        },
      );
    } catch (e) {
      print('Unexpected error in CreateUser: $e');
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }
}
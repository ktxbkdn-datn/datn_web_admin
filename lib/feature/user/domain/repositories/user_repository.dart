import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<Either<Failure, (List<UserEntity>, int)>> getAllUsers({
    int page,
    int limit,
    String? email,
    String? fullname,
    String? phone,
    String? className,
  });
  Future<Either<Failure, UserEntity>> getUserById(int userId);
  Future<Either<Failure, UserEntity>> createUser({
    required String email,
    required String fullname,
    String? phone,
  });
  Future<Either<Failure, UserEntity>> updateUser({
    required int userId,
    String? fullname,
    String? email,
    String? phone,
    String? cccd,
    DateTime? dateOfBirth,
    String? className,
  });
  Future<Either<Failure, void>> deleteUser(int userId);
}
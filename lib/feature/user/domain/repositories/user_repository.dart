import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<Either<Failure, (List<UserEntity>, int)>> getAllUsers({
    int page,
    int limit,
    String? keyword, 
    String? email,
    String? fullname,
    String? phone,
    String? className,
    String? hometown,        // thêm
    String? studentCode,     // thêm
  });
  Future<Either<Failure, UserEntity>> getUserById(int userId);
  Future<Either<Failure, UserEntity>> createUser({
    required String email,
    required String fullname,
    String? phone,
    String? hometown,        // thêm
    String? studentCode,     // thêm
  });
  Future<Either<Failure, UserEntity>> updateUser({
    required int userId,
    String? fullname,
    String? email,
    String? phone,
    String? cccd,
    DateTime? dateOfBirth,
    String? className,
    String? hometown,        // thêm
    String? studentCode,     // thêm
  });
  Future<Either<Failure, void>> deleteUser(int userId);
}
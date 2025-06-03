import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../datasources/user_datasource.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDataSource dataSource;

  UserRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, (List<UserEntity>, int)>> getAllUsers({
    int page = 1,
    int limit = 10,
    String? email,
    String? fullname,
    String? phone,
    String? className,
  }) async {
    try {
      final (users, total) = await dataSource.getAllUsers(
        page: page,
        limit: limit,
        email: email,
        fullname: fullname,
        phone: phone,
        className: className,
      );
      return Right((users.map((model) => model.toEntity()).toList(), total));
    } catch (e) {
      if (e is ServerFailure) {
        return Left(e);
      }
      if (e is NetworkFailure) {
        return Left(e);
      }
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserById(int userId) async {
    try {
      final user = await dataSource.getUserById(userId);
      return Right(user.toEntity());
    } catch (e) {
      if (e is ServerFailure) {
        return Left(e);
      }
      if (e is NetworkFailure) {
        return Left(e);
      }
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> createUser({
    required String email,
    required String fullname,
    String? phone,
  }) async {
    try {
      final user = await dataSource.createUser(
        email: email,
        fullname: fullname,
        phone: phone,
      );
      return Right(user.toEntity());
    } catch (e) {
      if (e is ServerFailure) {
        return Left(e);
      }
      if (e is NetworkFailure) {
        return Left(e);
      }
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUser({
    required int userId,
    String? fullname,
    String? email,
    String? phone,
    String? cccd,
    DateTime? dateOfBirth,
    String? className,
  }) async {
    try {
      final user = await dataSource.updateUser(
        userId: userId,
        fullname: fullname,
        email: email,
        phone: phone,
        cccd: cccd,
        dateOfBirth: dateOfBirth,
        className: className,
      );
      return Right(user.toEntity());
    } catch (e) {
      if (e is ServerFailure) {
        return Left(e);
      }
      if (e is NetworkFailure) {
        return Left(e);
      }
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(int userId) async {
    try {
      await dataSource.deleteUser(userId);
      return const Right(null);
    } catch (e) {
      if (e is ServerFailure) {
        return Left(e);
      }
      if (e is NetworkFailure) {
        return Left(e);
      }
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }
}
import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/feature/user/domain/entities/user_entity.dart';
import 'package:datn_web_admin/feature/user/domain/repositories/user_repository.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';

class GetAllUsers {
  final UserRepository repository;

  GetAllUsers(this.repository);

  Future<Either<Failure, (List<UserEntity>, int)>> call({
    int page = 1,
    int limit = 10,
    String? keyword, 
    String? email,
    String? fullname,
    String? phone,
    String? className,
  }) async {
    try {
      print('Calling GetAllUsers with page: $page, limit: $limit');
      final result = await repository.getAllUsers(
        page: page,
        limit: limit,
        keyword: keyword, 
        email: email,
        fullname: fullname,
        phone: phone,
        className: className,
      );
      return result.fold(
        (failure) {
          print('GetAllUsers failed: ${failure.message}');
          return Left(failure);
        },
        (data) {
          final (users, total) = data;
          print('GetAllUsers successful, fetched ${users.length} users, total: $total');
          return Right((users, total));
        },
      );
    } catch (e) {
      print('Unexpected error in GetAllUsers: $e');
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }
}

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

class UpdateUser {
  final UserRepository repository;

  UpdateUser(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required int userId,
    String? fullname,
    String? email,
    String? phone,
    String? cccd,
    DateTime? dateOfBirth,
    String? className,
  }) async {
    try {
      print('Calling UpdateUser for user ID: $userId');
      final result = await repository.updateUser(
        userId: userId,
        fullname: fullname,
        email: email,
        phone: phone,
        cccd: cccd,
        dateOfBirth: dateOfBirth,
        className: className,
      );
      return result.fold(
        (failure) {
          print('UpdateUser failed: ${failure.message}');
          return Left(failure);
        },
        (user) {
          print('UpdateUser successful for user ID: $userId');
          return Right(user);
        },
      );
    } catch (e) {
      print('Unexpected error in UpdateUser: $e');
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }
}

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
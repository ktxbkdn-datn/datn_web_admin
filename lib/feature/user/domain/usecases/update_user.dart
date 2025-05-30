// lib/src/features/user/domain/usecases/update_user.dart
import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

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
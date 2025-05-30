// lib/src/features/user/domain/usecases/get_all_users.dart
import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetAllUsers {
  final UserRepository repository;

  GetAllUsers(this.repository);

  Future<Either<Failure, List<UserEntity>>> call({
    int page = 1,
    int limit = 10,
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
            (users) {
          print('GetAllUsers successful, fetched ${users.length} users');
          return Right(users);
        },
      );
    } catch (e) {
      print('Unexpected error in GetAllUsers: $e');
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }
}
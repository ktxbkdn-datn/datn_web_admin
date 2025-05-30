
import 'package:dartz/dartz.dart';

import '../../../../../src/core/error/failures.dart';
import '../../entities/service_entity.dart';
import '../../repository/service_repository.dart';

class GetAllServices {
  final ServiceRepository repository;

  GetAllServices({required this.repository});

  Future<Either<Failure, List<Service>>> call({int page = 1, int limit = 10}) async {
    return await repository.getAllServices(page: page, limit: limit);
  }
}
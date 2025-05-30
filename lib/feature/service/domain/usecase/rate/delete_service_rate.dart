import 'package:dartz/dartz.dart';
import '../../../../../src/core/error/failures.dart';
import '../../repository/service_repository.dart';


class DeleteServiceRate {
  final ServiceRepository repository;

  DeleteServiceRate({required this.repository});

  Future<Either<Failure, void>> call(int rateId) async {
    return await repository.deleteServiceRate(rateId);
  }
}
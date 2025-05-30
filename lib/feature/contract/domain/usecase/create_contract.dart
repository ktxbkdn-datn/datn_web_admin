import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entities/contract_entity.dart';
import '../repository/contract_repository.dart';

class CreateContract {
  final ContractRepository repository;

  CreateContract(this.repository);

  Future<Either<Failure, Contract>> call(Contract contract, int areaId) async {
    return await repository.createContract(contract, areaId);
  }
}
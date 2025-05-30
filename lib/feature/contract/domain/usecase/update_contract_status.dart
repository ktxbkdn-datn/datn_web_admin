import 'package:dartz/dartz.dart';

import '../../../../../src/core/error/failures.dart';
import '../repository/contract_repository.dart';

class UpdateContractStatus {
  final ContractRepository repository;

  UpdateContractStatus(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.updateContractStatus();
  }
}
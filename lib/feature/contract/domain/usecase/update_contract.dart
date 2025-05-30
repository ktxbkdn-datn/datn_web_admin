import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../../../admin/presentation/bloc/admin_state.dart';
import '../entities/contract_entity.dart';
import '../repository/contract_repository.dart';


class UpdateContract {
  final ContractRepository repository;

  UpdateContract(this.repository);

  Future<Either<Failure, Contract>> call(int contractId, Contract contract, int areaId) async {
    return await repository.updateContract(contractId, contract, areaId);
  }
}
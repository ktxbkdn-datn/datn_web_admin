import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../../../admin/presentation/bloc/admin_state.dart';
import '../entities/contract_entity.dart';
import '../repository/contract_repository.dart';

class GetContractById {
  final ContractRepository repository;

  GetContractById(this.repository);

  Future<Either<Failure, Contract>> call(int contractId) async {
    return await repository.getContractById(contractId);
  }
}
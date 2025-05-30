import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../../../admin/presentation/bloc/admin_state.dart';
import '../repository/contract_repository.dart';

class DeleteContract {
  final ContractRepository repository;

  DeleteContract(this.repository);

  Future<Either<Failure, void>> call(int contractId) async {
    return await repository.deleteContract(contractId);
  }
}
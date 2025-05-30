import 'package:dartz/dartz.dart';

import '../../../admin/presentation/bloc/admin_state.dart';
import '../entities/contract_entity.dart';
import '../repository/contract_repository.dart';
import '../../../../src/core/error/failures.dart';


class GetAllContracts {
  final ContractRepository repository;

  GetAllContracts(this.repository);

  Future<Either<Failure, List<Contract>>> call({
    int page = 1,
    int limit = 10,
    String? email,
    String? status,
    String? startDate,
    String? endDate,
    String? contractType,
  }) async {
    return await repository.getAllContracts(
      page: page,
      limit: limit,
      email: email,
      status: status,
      startDate: startDate,
      endDate: endDate,
      contractType: contractType,
    );
  }
}
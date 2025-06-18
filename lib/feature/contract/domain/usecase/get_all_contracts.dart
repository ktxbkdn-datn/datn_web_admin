import 'package:dartz/dartz.dart';
import '../entities/contract_entity.dart';
import '../repository/contract_repository.dart';
import '../../../../src/core/error/failures.dart';

class GetAllContracts {
  final ContractRepository repository;

  GetAllContracts(this.repository);

  Future<Either<Failure, (List<Contract>, int)>> call({
    int page = 1,
    int limit = 10,
    String? keyword, 
    String? email,
    String? status,
    String? startDate,
    String? endDate,
    String? contractType,
  }) async {
    return await repository.getAllContracts(
      page: page,
      limit: limit,
      keyword: keyword, 
      email: email,
      status: status,
      startDate: startDate,
      endDate: endDate,
      contractType: contractType,
    );
  }
}
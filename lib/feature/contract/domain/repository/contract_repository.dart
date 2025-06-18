import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entities/contract_entity.dart';

abstract class ContractRepository {
  Future<Either<Failure, (List<Contract>, int)>> getAllContracts({ // Trả về tuple
    int page = 1,
    int limit = 10,
    String? keyword, 
    String? email,
    String? status,
    String? startDate,
    String? endDate,
    String? contractType,
  });

  Future<Either<Failure, Contract>> getContractById(int contractId);
  Future<Either<Failure, Contract>> createContract(Contract contract, int areaId);
  Future<Either<Failure, Contract>> updateContract(int contractId, Contract contract, int areaId);
  Future<Either<Failure, void>> deleteContract(int contractId);
  Future<Either<Failure, void>> updateContractStatus();
}
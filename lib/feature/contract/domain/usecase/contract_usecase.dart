import 'package:dartz/dartz.dart';
import 'dart:typed_data';
import 'package:datn_web_admin/feature/contract/domain/entities/contract_entity.dart';
import 'package:datn_web_admin/feature/contract/domain/repository/contract_repository.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';

class CreateContract {
  final ContractRepository repository;

  CreateContract(this.repository);

  Future<Either<Failure, Contract>> call(Contract contract, int areaId, String studentCode) async {
    return await repository.createContract(contract, areaId, studentCode);
  }
}
class DeleteContract {
  final ContractRepository repository;

  DeleteContract(this.repository);

  Future<Either<Failure, void>> call(int contractId) async {
    return await repository.deleteContract(contractId);
  }
}
class ExportContractPdf {
  final ContractRepository repository;
  ExportContractPdf(this.repository);
  Future<Either<Failure, Uint8List>> call(int contractId) async {
    return await repository.exportContractPdf(contractId);
  }
}

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

class GetContractById {
  final ContractRepository repository;

  GetContractById(this.repository);

  Future<Either<Failure, Contract>> call(int contractId) async {
    return await repository.getContractById(contractId);
  }
}


class UpdateContract {
  final ContractRepository repository;

  UpdateContract(this.repository);

  Future<Either<Failure, Contract>> call(int contractId, Contract contract, int areaId) async {
    return await repository.updateContract(contractId, contract, areaId);
  }
}

class UpdateContractStatus {
  final ContractRepository repository;

  UpdateContractStatus(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.updateContractStatus();
  }
}


import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../../domain/entities/contract_entity.dart';
import '../../domain/repository/contract_repository.dart';
import '../datasource/contract_data_source.dart';
import '../models/contract_model.dart';

class ContractRepositoryImpl implements ContractRepository {
  final ContractRemoteDataSource remoteDataSource;

  ContractRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, (List<Contract>, int)>> getAllContracts({
    int page = 1,
    int limit = 10,
    String? email,
    String? status,
    String? startDate,
    String? endDate,
    String? contractType,
  }) async {
    try {
      final (models, totalItems) = await remoteDataSource.getAllContracts(
        page: page,
        limit: limit,
        email: email,
        status: status,
        startDate: startDate,
        endDate: endDate,
        contractType: contractType,
      );
      return Right((models.map((model) => model.toEntity()).toList(), totalItems));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  // Các phương thức khác giữ nguyên
  @override
  Future<Either<Failure, Contract>> getContractById(int contractId) async {
    try {
      final result = await remoteDataSource.getContractById(contractId);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, Contract>> createContract(Contract contract, int areaId) async {
    try {
      final contractModel = ContractModel(
        contractId: 0,
        roomId: 0,
        userId: 0,
        status: contract.status,
        createdAt: contract.createdAt,
        contractType: contract.contractType,
        startDate: contract.startDate,
        endDate: contract.endDate,
        roomName: contract.roomName,
        userEmail: contract.userEmail,
      );
      final result = await remoteDataSource.createContract(contractModel, areaId);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, Contract>> updateContract(int contractId, Contract contract, int areaId) async {
    try {
      final contractModel = ContractModel(
        contractId: contractId,
        roomId: 0,
        userId: 0,
        status: contract.status,
        createdAt: contract.createdAt,
        contractType: contract.contractType,
        startDate: contract.startDate,
        endDate: contract.endDate,
        roomName: contract.roomName,
        userEmail: contract.userEmail,
      );
      final result = await remoteDataSource.updateContract(contractId, contractModel, areaId);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteContract(int contractId) async {
    try {
      final result = await remoteDataSource.deleteContract(contractId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateContractStatus() async {
    try {
      await remoteDataSource.updateContractStatus();
      return Right(null);
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }
}
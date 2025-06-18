import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../../../../src/core/network/api_client.dart';
import '../../domain/entities/contract_entity.dart';
import '../models/contract_model.dart';

abstract class ContractRemoteDataSource {
  Future<(List<ContractModel>, int)> getAllContracts({ // Trả về tuple
    int page,
    int limit,
    String? keyword, 
    String? email,
    String? status,
    String? startDate,
    String? endDate,
    String? contractType,
  });

  Future<ContractModel> getContractById(int contractId);
  Future<ContractModel> createContract(ContractModel contract, int areaId);
  Future<ContractModel> updateContract(int contractId, ContractModel contract, int areaId);
  Future<void> deleteContract(int contractId);
  Future<void> updateContractStatus();
}

class ContractRemoteDataSourceImpl implements ContractRemoteDataSource {
  final ApiService apiService;

  ContractRemoteDataSourceImpl(this.apiService);

  @override
  Future<(List<ContractModel>, int)> getAllContracts({
    int page = 1,
    int limit = 10,
    String? keyword, 
    String? email,
    String? status,
    String? startDate,
    String? endDate,
    String? contractType,
  }) async {
    try {
      final response = await apiService.get(
        '/contracts',
        queryParams: {
          'page': page.toString(),
          'limit': limit.toString(),
          if (keyword != null && keyword.isNotEmpty) 'keyword': keyword, // Thêm dòng này
          if (email != null) 'email': email,
          if (status != null) 'status': status,
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
          if (contractType != null) 'contract_type': contractType,
        },
      );

      final contractsJson = response['contracts'] as List<dynamic>;
      final totalItems = response['total'] as int; // Lấy từ response
      return (
        contractsJson.map((json) => ContractModel.fromJson(json)).toList(),
        totalItems,
      );
    } catch (e) {
      if (e is ServerFailure) {
        throw ServerFailure(e.message);
      } else if (e is NetworkFailure) {
        throw NetworkFailure(e.message);
      }
      throw ServerFailure('Không thể lấy hợp đồng: $e');
    }
  }

  // Các phương thức khác giữ nguyên
  @override
  Future<ContractModel> getContractById(int contractId) async {
    try {
      final response = await apiService.get('/contracts/$contractId');
      return ContractModel.fromJson(response);
    } catch (e) {
      if (e is ServerFailure) {
        throw ServerFailure(e.message);
      } else if (e is NetworkFailure) {
        throw NetworkFailure(e.message);
      }
      throw ServerFailure('Không thể lấy hợp đồng: $e');
    }
  }

  @override
  Future<ContractModel> createContract(ContractModel contract, int areaId) async {
    try {
      final jsonData = contract.toJson()..['area_id'] = areaId;
      final response = await apiService.post('/admin/contracts', jsonData);
      return ContractModel.fromJson(response);
    } catch (e) {
      if (e is ServerFailure) {
        throw ServerFailure(e.message);
      } else if (e is NetworkFailure) {
        throw NetworkFailure(e.message);
      }
      throw ServerFailure('Không thể tạo hợp đồng: $e');
    }
  }

  @override
  Future<ContractModel> updateContract(int contractId, ContractModel contract, int areaId) async {
    try {
      final jsonData = contract.toJson()..['area_id'] = areaId;
      final response = await apiService.put('/admin/contracts/$contractId', jsonData);
      return ContractModel.fromJson(response);
    } catch (e) {
      if (e is ServerFailure) {
        throw ServerFailure(e.message);
      } else if (e is NetworkFailure) {
        throw NetworkFailure(e.message);
      }
      throw ServerFailure('Không thể cập nhật hợp đồng: $e');
    }
  }

  @override
  Future<void> deleteContract(int contractId) async {
    try {
      await apiService.delete('/admin/contracts/$contractId');
    } catch (e) {
      if (e is ServerFailure) {
        throw ServerFailure(e.message);
      } else if (e is NetworkFailure) {
        throw NetworkFailure(e.message);
      }
      throw ServerFailure('Không thể xóa hợp đồng: $e');
    }
  }

  @override
  Future<void> updateContractStatus() async {
    try {
      await apiService.post('/admin/update-contract-status', {});
    } catch (e) {
      if (e is ServerFailure) {
        throw ServerFailure(e.message);
      } else if (e is NetworkFailure) {
        throw NetworkFailure(e.message);
      }
      throw ServerFailure('Không thể cập nhật trạng thái hợp đồng: $e');
    }
  }
}
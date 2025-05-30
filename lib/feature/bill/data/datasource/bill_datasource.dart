import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';
import 'package:datn_web_admin/feature/bill/data/models/bill_detail_model.dart';
import 'package:datn_web_admin/feature/bill/data/models/monthly_bill_model.dart';
import 'package:datn_web_admin/src/core/network/api_client.dart';
import 'package:intl/intl.dart';

abstract class BillRemoteDataSource {
  Future<Either<Failure, Map<String, dynamic>>> createMonthlyBillsBulk({
    required DateTime billMonth,
    List<int>? roomIds,
  });
  Future<Either<Failure, List<BillDetailModel>>> getAllBillDetails();
  Future<Either<Failure, List<MonthlyBillModel>>> getAllMonthlyBills();
  Future<Either<Failure, Map<String, List<int>>>> deletePaidBills(List<int> billIds);
  Future<Either<Failure, void>> deleteBillDetail(int detailId);
  Future<Either<Failure, void>> deleteMonthlyBill(int billId); // Thêm phương thức xóa MonthlyBill
}

class BillRemoteDataSourceImpl implements BillRemoteDataSource {
  final ApiService apiService;

  BillRemoteDataSourceImpl(this.apiService);

  @override
  Future<Either<Failure, Map<String, dynamic>>> createMonthlyBillsBulk({
    required DateTime billMonth,
    List<int>? roomIds,
  }) async {
    try {
      final body = {
        'bill_month': DateFormat('yyyy-MM').format(billMonth),
        if (roomIds != null) 'room_ids': roomIds,
      };
      final response = await apiService.post('/admin/monthly-bills/bulk', body);
      return Right({
        'bills_created': (response['bills_created'] as List)
            .map((json) => json as Map<String, dynamic>)
            .toList(),
        'errors': (response['errors'] as List)
            .map((json) => json as Map<String, dynamic>)
            .toList(),
        'message': response['message'] as String,
      });
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<BillDetailModel>>> getAllBillDetails() async {
    try {
      final response = await apiService.get('/admin/bill-details');
      final billDetails = (response as List)
          .map((json) => BillDetailModel.fromJson(json))
          .toList();
      return Right(billDetails);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<MonthlyBillModel>>> getAllMonthlyBills() async {
    try {
      final response = await apiService.get('/admin/monthly-bills');
      final monthlyBills = (response as List)
          .map((json) => MonthlyBillModel.fromJson(json))
          .toList();
      return Right(monthlyBills);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, List<int>>>> deletePaidBills(List<int> billIds) async {
    try {
      final body = {
        'bill_ids': billIds,
      };
      final response = await apiService.delete('/admin/paid-bills', data: body);
      final deletedIds = {
        'deleted_monthly_bills': (response['deleted_monthly_bills'] as List).cast<int>(),
        'deleted_bill_details': (response['deleted_bill_details'] as List).cast<int>(),
      };
      return Right(deletedIds);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBillDetail(int detailId) async {
    try {
      await apiService.delete('/admin/bill-details/$detailId');
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMonthlyBill(int billId) async {
    try {
      await apiService.delete('/admin/monthly-bills/$billId');
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Failure _handleError(dynamic error) {
    if (error is ServerFailure) {
      return ServerFailure(error.message);
    } else if (error is NetworkFailure) {
      return NetworkFailure(error.message);
    } else {
      return ServerFailure('Không thể kết nối tới server');
    }
  }
}
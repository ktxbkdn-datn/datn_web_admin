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
  Future<Either<Failure, Map<String, dynamic>>> getAllBillDetails({
    int page = 1,
    int limit = 20,
    String? area,
    String? service,
    String? billStatus,
    String? paymentStatus,
    String? search,
    String? month,
    String? submissionStatus, // Thêm tham số mới
  });
  Future<Either<Failure, (List<MonthlyBillModel>, int)>> getAllMonthlyBills({required int page, required int limit, String? paymentStatus, String? area, String? service, String? month, String? billStatus, String? search});
  Future<Either<Failure, Map<String, List<int>>>> deletePaidBills(List<int> billIds);
  Future<Either<Failure, void>> deleteBillDetail(int detailId);
  Future<Either<Failure, void>> deleteMonthlyBill(int billId);
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
  Future<Either<Failure, Map<String, dynamic>>> getAllBillDetails({
    int page = 1,
    int limit = 20,
    String? area,
    String? service,
    String? billStatus,
    String? paymentStatus,
    String? search,
    String? month,
    String? submissionStatus,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (area != null && area != 'All') 'area': area,
        if (service != null && service != 'All') 'service': service,
        if (billStatus != null && billStatus != 'All') 'billStatus': billStatus,
        if (paymentStatus != null && paymentStatus != 'All') 'paymentStatus': paymentStatus,
        if (search != null && search.isNotEmpty) 'search': search,
        if (month != null) 'month': month,
        if (submissionStatus != null && submissionStatus != 'All') 'submissionStatus': submissionStatus,
      };
      final response = await apiService.get('/admin/bill-details', queryParams: queryParams);

      final billDetails = (response['bill_details'] as List)
          .map((json) => BillDetailModel.fromJson(json))
          .toList();
      final total = response['total'] as int? ?? 0;
      final pages = response['pages'] as int? ?? 1;
      final currentPage = response['current_page'] as int? ?? 1;

      return Right({
        'billDetails': billDetails,
        'total': total,
        'pages': pages,
        'currentPage': currentPage,
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, (List<MonthlyBillModel>, int)>> getAllMonthlyBills({
    required int page,
    required int limit,
    String? area,
    String? paymentStatus,
    String? service,
    String? month,
    String? billStatus,
    String? search,
  }) async {
    try {
      print('[DEBUG] Truyền month lên API: $month');
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (area != null) 'area': area,
        if (paymentStatus != null) 'payment_status': paymentStatus,
        if (service != null) 'service': service,
        if (month != null) 'month': month,
        if (billStatus != null) 'bill_status': billStatus,
        if (search != null) 'search': search,
      };
      final response = await apiService.get('/admin/monthly-bills', queryParams: queryParams);

      final billModels = ((response['bills'] ?? []) as List)
          .map((json) => MonthlyBillModel.fromJson(json))
          .toList();
      final total = response['total'] as int? ?? 0;
      return Right((billModels, total));
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
      return ServerFailure(error.toString());
    }
  }
}


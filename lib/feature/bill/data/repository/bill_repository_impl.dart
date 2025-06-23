import 'package:dartz/dartz.dart';
import 'package:datn_web_admin/feature/bill/data/models/monthly_bill_model.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';
import 'package:datn_web_admin/feature/bill/domain/entities/bill_detail_entity.dart';
import 'package:datn_web_admin/feature/bill/domain/entities/monthly_bill_entity.dart';
import '../../domain/repository/bill_repository.dart';
import '../datasource/bill_datasource.dart';

class BillRepositoryImpl implements BillRepository {
  final BillRemoteDataSource remoteDataSource;

  BillRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Map<String, dynamic>>> createMonthlyBillsBulk({
    required DateTime billMonth,
    List<int>? roomIds,
  }) async {
    try {
      final result = await remoteDataSource.createMonthlyBillsBulk(
        billMonth: billMonth,
        roomIds: roomIds,
      );
      return result;
    } catch (e) {
      if (e is ServerFailure) {
        return Left(ServerFailure(e.message));
      } else if (e is NetworkFailure) {
        return Left(NetworkFailure(e.message));
      } else {
        return Left(ServerFailure('Không thể tạo hóa đơn'));
      }
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
    final result = await remoteDataSource.getAllBillDetails(
      page: page,
      limit: limit,
      area: area,
      service: service,
      billStatus: billStatus,
      paymentStatus: paymentStatus,
      search: search,
      month: month,
      submissionStatus: submissionStatus,
    );
    return result;
  }

  @override
  Future<Either<Failure, (List<MonthlyBill>, int)>> getAllMonthlyBills({
    required int page,
    required int limit,
    String? area,
    String? paymentStatus,
    String? service,
    String? month,
    String? billStatus,
    String? search,
  }) async {
    final result = await remoteDataSource.getAllMonthlyBills(
      page: page,
      limit: limit,
      area: area,
      paymentStatus: paymentStatus,
      service: service,
      month: month,
      billStatus: billStatus,
      search: search,
    );
    // Chuyển model thành entity trước khi trả về
    return result.map((data) => (
      data.$1.map((model) => model.toEntity()).toList(),
      data.$2
    ));
  }

  @override
  Future<Either<Failure, Map<String, List<int>>>> deletePaidBills(List<int> billIds) async {
    try {
      final result = await remoteDataSource.deletePaidBills(billIds);
      return result;
    } catch (e) {
      if (e is ServerFailure) {
        return Left(ServerFailure(e.message));
      } else if (e is NetworkFailure) {
        return Left(NetworkFailure(e.message));
      } else {
        return Left(ServerFailure('Không thể xóa hóa đơn đã thanh toán'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> deleteBillDetail(int detailId) async {
    try {
      final result = await remoteDataSource.deleteBillDetail(detailId);
      return result;
    } catch (e) {
      if (e is ServerFailure) {
        return Left(ServerFailure(e.message));
      } else if (e is NetworkFailure) {
        return Left(NetworkFailure(e.message));
      } else {
        return Left(ServerFailure('Không thể xóa chi tiết hóa đơn'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> deleteMonthlyBill(int billId) async {
    try {
      final result = await remoteDataSource.deleteMonthlyBill(billId);
      return result;
    } catch (e) {
      if (e is ServerFailure) {
        return Left(ServerFailure(e.message));
      } else if (e is NetworkFailure) {
        return Left(NetworkFailure(e.message));
      } else {
        return Left(ServerFailure('Không thể xóa hóa đơn hàng tháng'));
      }
    }
  }
  @override
  Future<Either<Failure, Map<String, dynamic>>> notifyRemindBillDetail({
    required String billMonth,
  }) async {
    try {
      final result = await remoteDataSource.notifyRemindBillDetail(
        billMonth: billMonth,
      );
      return result;
    } catch (e) {
      if (e is ServerFailure) {
        return Left(ServerFailure(e.message));
      } else if (e is NetworkFailure) {
        return Left(NetworkFailure(e.message));
      } else {
        return Left(ServerFailure('Không thể gửi thông báo nhắc nhở'));
      }
    }
  }
  @override
  Future<Either<Failure, Map<String, dynamic>>> notifyRemindPayment({
    required String billMonth,
  }) async {
    try {
      final result = await remoteDataSource.notifyRemindPayment(
        billMonth: billMonth,
      );
      return result;
    } catch (e) {
      if (e is ServerFailure) {
        return Left(ServerFailure(e.message));
      } else if (e is NetworkFailure) {
        return Left(NetworkFailure(e.message));
      } else {
        return Left(ServerFailure('Không thể gửi thông báo nhắc thanh toán'));
      }
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getRoomBillDetails({
    required int roomId,
    required int year,
    required int serviceId,
  }) async {
    try {
      final result = await remoteDataSource.getRoomBillDetails(
        roomId: roomId,
        year: year,
        serviceId: serviceId,
      );
      return result;
    } catch (e) {
      if (e is ServerFailure) {
        return Left(ServerFailure(e.message));
      } else if (e is NetworkFailure) {
        return Left(NetworkFailure(e.message));
      } else {
        return Left(ServerFailure('Không thể lấy chi tiết chỉ số phòng'));
      }
    }
  }
}
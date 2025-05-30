import 'package:dartz/dartz.dart';
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
  Future<Either<Failure, List<BillDetail>>> getAllBillDetails() async {
    try {
      final result = await remoteDataSource.getAllBillDetails();
      return result.map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      if (e is ServerFailure) {
        return Left(ServerFailure(e.message));
      } else if (e is NetworkFailure) {
        return Left(NetworkFailure(e.message));
      } else {
        return Left(ServerFailure('Không thể lấy danh sách chi tiết hóa đơn'));
      }
    }
  }

  @override
  Future<Either<Failure, List<MonthlyBill>>> getAllMonthlyBills() async {
    try {
      final result = await remoteDataSource.getAllMonthlyBills();
      return result.map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      if (e is ServerFailure) {
        return Left(ServerFailure(e.message));
      } else if (e is NetworkFailure) {
        return Left(NetworkFailure(e.message));
      } else {
        return Left(ServerFailure('Không thể lấy danh sách hóa đơn hàng tháng'));
      }
    }
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
}
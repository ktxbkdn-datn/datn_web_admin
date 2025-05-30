import 'package:get_it/get_it.dart';

import '../../../../feature/bill/data/datasource/bill_datasource.dart';
import '../../../../feature/bill/data/repository/bill_repository_impl.dart';
import '../../../../feature/bill/domain/repository/bill_repository.dart';
import '../../../../feature/bill/domain/usecase/create_monthly_bill_bulk.dart';
import '../../../../feature/bill/domain/usecase/delete_paid_bills.dart';
import '../../../../feature/bill/domain/usecase/get_all_bill_details.dart';
import '../../../../feature/bill/domain/usecase/get_all_monthly_bills.dart';
import '../../../../feature/bill/domain/usecase/delete_bill_detail.dart';
import '../../../../feature/bill/domain/usecase/delete_monthly_bill.dart'; // Thêm import
import '../../../../feature/bill/presentation/bloc/bill_bloc.dart';
import '../../network/api_client.dart';

final getIt = GetIt.instance;

void registerBillDependencies() {
  // Đăng ký Data Source
  getIt.registerSingleton<BillRemoteDataSource>(BillRemoteDataSourceImpl(getIt<ApiService>()));

  // Đăng ký Repository
  getIt.registerSingleton<BillRepository>(
    BillRepositoryImpl(getIt<BillRemoteDataSource>()),
  );

  // Đăng ký UseCases
  getIt.registerSingleton<CreateMonthlyBillsBulk>(
    CreateMonthlyBillsBulk(getIt<BillRepository>()),
  );
  getIt.registerSingleton<GetAllBillDetails>(
    GetAllBillDetails(getIt<BillRepository>()),
  );
  getIt.registerSingleton<GetAllMonthlyBills>(
    GetAllMonthlyBills(getIt<BillRepository>()),
  );
  getIt.registerSingleton<DeletePaidBills>(
    DeletePaidBills(getIt<BillRepository>()),
  );
  getIt.registerSingleton<DeleteBillDetail>(
    DeleteBillDetail(getIt<BillRepository>()), // Đăng ký DeleteBillDetail
  );
  getIt.registerSingleton<DeleteMonthlyBill>(
    DeleteMonthlyBill(getIt<BillRepository>()), // Đăng ký DeleteMonthlyBill
  );

  // Đăng ký Bloc
  getIt.registerFactory<BillBloc>(() => BillBloc(
    createMonthlyBillsBulk: getIt<CreateMonthlyBillsBulk>(),
    getAllBillDetails: getIt<GetAllBillDetails>(),
    getAllMonthlyBills: getIt<GetAllMonthlyBills>(),
    deletePaidBills: getIt<DeletePaidBills>(),
    deleteBillDetail: getIt<DeleteBillDetail>(), // Cung cấp deleteBillDetail
    deleteMonthlyBill: getIt<DeleteMonthlyBill>(), // Cung cấp deleteMonthlyBill
  ));
}
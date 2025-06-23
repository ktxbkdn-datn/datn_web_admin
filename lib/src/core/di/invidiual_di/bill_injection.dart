import 'package:datn_web_admin/feature/bill/domain/usecase/bill_usecase.dart';
import 'package:get_it/get_it.dart';

import '../../../../feature/bill/data/datasource/bill_datasource.dart';
import '../../../../feature/bill/data/repository/bill_repository_impl.dart';
import '../../../../feature/bill/domain/repository/bill_repository.dart';

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
  );  getIt.registerSingleton<NotifyRemindBillDetail>(
    NotifyRemindBillDetail(getIt<BillRepository>()),
  );
  getIt.registerSingleton<NotifyRemindPayment>(
    NotifyRemindPayment(getIt<BillRepository>()),
  );
  getIt.registerSingleton<GetRoomBillDetails>(
    GetRoomBillDetails(getIt<BillRepository>()),
  );
  // Đăng ký Bloc
  getIt.registerFactory<BillBloc>(() => BillBloc(
    createMonthlyBillsBulk: getIt<CreateMonthlyBillsBulk>(),
    getAllBillDetails: getIt<GetAllBillDetails>(),
    getAllMonthlyBills: getIt<GetAllMonthlyBills>(),
    deletePaidBills: getIt<DeletePaidBills>(),
    deleteBillDetail: getIt<DeleteBillDetail>(), // Cung cấp deleteBillDetail
    deleteMonthlyBill: getIt<DeleteMonthlyBill>(), // Cung cấp deleteMonthlyBill
    notifyRemindBillDetail: getIt<NotifyRemindBillDetail>(),
    notifyRemindPayment: getIt<NotifyRemindPayment>(),
    getRoomBillDetails: getIt<GetRoomBillDetails>(),
  ));
}
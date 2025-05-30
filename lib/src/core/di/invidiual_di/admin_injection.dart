import 'package:get_it/get_it.dart';

import '../../../../feature/admin/data/datasources/admin_datasource.dart';
import '../../../../feature/admin/data/repositories/admin_repository_impl.dart';
import '../../../../feature/admin/domain/repositories/admin_repository.dart';
import '../../../../feature/admin/domain/usecase/change_password.dart';
import '../../../../feature/admin/domain/usecase/confirm_reset_password.dart';
import '../../../../feature/admin/domain/usecase/create_admin.dart';
import '../../../../feature/admin/domain/usecase/delete_admin.dart';
import '../../../../feature/admin/domain/usecase/get_admin_by_id.dart';
import '../../../../feature/admin/domain/usecase/get_all_admins.dart';
import '../../../../feature/admin/domain/usecase/request_password_reset.dart';
import '../../../../feature/admin/domain/usecase/update_admin.dart';
import '../../../../feature/admin/presentation/bloc/admin_bloc.dart';
import '../../network/api_client.dart';

final getIt = GetIt.instance;

void registerAdminDependencies() {
  getIt.registerSingleton<AdminDataSource>(AdminDataSource(getIt<ApiService>()));
  getIt.registerSingleton<AdminRepository>(AdminRepositoryImpl(getIt<AdminDataSource>()));
  getIt.registerSingleton<GetAllAdmins>(GetAllAdmins(getIt<AdminRepository>()));
  getIt.registerSingleton<GetAdminById>(GetAdminById(getIt<AdminRepository>()));
  getIt.registerSingleton<CreateAdmin>(CreateAdmin(getIt<AdminRepository>()));
  getIt.registerSingleton<UpdateAdmin>(UpdateAdmin(getIt<AdminRepository>()));
  getIt.registerSingleton<DeleteAdmin>(DeleteAdmin(getIt<AdminRepository>()));
  getIt.registerSingleton<RequestPasswordReset>(RequestPasswordReset(getIt<AdminRepository>()));
  getIt.registerSingleton<ConfirmResetPassword>(ConfirmResetPassword(getIt<AdminRepository>()));
  getIt.registerSingleton<ChangePassword>(ChangePassword(getIt<AdminRepository>()));
  getIt.registerFactory<AdminBloc>(() => AdminBloc(
    getAllAdmins: getIt<GetAllAdmins>(),
    getAdminById: getIt<GetAdminById>(),
    createAdmin: getIt<CreateAdmin>(),
    updateAdmin: getIt<UpdateAdmin>(),
    deleteAdmin: getIt<DeleteAdmin>(),
    requestPasswordReset: getIt<RequestPasswordReset>(),
    confirmResetPassword: getIt<ConfirmResetPassword>(),
    changePassword: getIt<ChangePassword>(),
  ));
}
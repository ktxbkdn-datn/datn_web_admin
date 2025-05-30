import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../src/core/error/failures.dart';
import '../../domain/entities/admin_entity.dart';
import '../../domain/usecase/change_password.dart';
import '../../domain/usecase/confirm_reset_password.dart';
import '../../domain/usecase/create_admin.dart';
import '../../domain/usecase/delete_admin.dart';
import '../../domain/usecase/get_admin_by_id.dart';
import '../../domain/usecase/get_all_admins.dart';
import '../../domain/usecase/request_password_reset.dart';
import '../../domain/usecase/update_admin.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetAllAdmins getAllAdmins;
  final GetAdminById getAdminById;
  final CreateAdmin createAdmin;
  final UpdateAdmin updateAdmin;
  final DeleteAdmin deleteAdmin;
  final RequestPasswordReset requestPasswordReset;
  final ConfirmResetPassword confirmResetPassword;
  final ChangePassword changePassword;
  List<AdminEntity> _admins = []; // Lưu trữ danh sách admin cục bộ

  AdminBloc({
    required this.getAllAdmins,
    required this.getAdminById,
    required this.createAdmin,
    required this.updateAdmin,
    required this.deleteAdmin,
    required this.requestPasswordReset,
    required this.confirmResetPassword,
    required this.changePassword,
  }) : super(AdminInitial()) {
    on<FetchAllAdminsEvent>(_onFetchAllAdmins);
    on<FetchAdminByIdEvent>(_onFetchAdminById);
    on<FetchCurrentAdminEvent>(_onFetchCurrentAdmin);
    on<CreateAdminEvent>(_onCreateAdmin);
    on<UpdateAdminEvent>(_onUpdateAdmin);
    on<DeleteAdminEvent>(_onDeleteAdmin);
    on<RequestPasswordResetEvent>(_onRequestPasswordReset);
    on<ConfirmResetPasswordEvent>(_onConfirmResetPassword);
    on<ChangePasswordEvent>(_onChangePassword);
  }

  Future<void> _onFetchAllAdmins(FetchAllAdminsEvent event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await getAllAdmins(page: event.page, limit: event.limit);
    result.fold(
          (failure) {
        print('Failure in _onFetchAllAdmins: $failure, message: ${failure.message}');
        emit(AdminError(failure: failure));
      },
          (admins) {
        _admins = admins; // Cập nhật danh sách admin cục bộ
        emit(AdminListLoaded(admins: admins));
      },
    );
  }

  Future<void> _onFetchAdminById(FetchAdminByIdEvent event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await getAdminById(event.adminId);
    result.fold(
          (failure) {
        print('Failure in _onFetchAdminById: $failure, message: ${failure.message}');
        emit(AdminError(failure: failure));
      },
          (admin) {
        // Cập nhật danh sách admin cục bộ nếu admin đã tồn tại
        final updatedAdmins = _admins.map((a) => a.adminId == admin.adminId ? admin : a).toList();
        if (!_admins.any((a) => a.adminId == admin.adminId)) {
          updatedAdmins.add(admin);
        }
        _admins = updatedAdmins;
        emit(AdminListLoaded(admins: _admins));
      },
    );
  }

  Future<void> _onFetchCurrentAdmin(FetchCurrentAdminEvent event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await getAdminById(event.adminId);
    result.fold(
          (failure) {
        print('Failure in _onFetchCurrentAdmin: $failure, message: ${failure.message}');
        emit(AdminError(failure: failure));
      },
          (admin) => emit(AdminUpdated(currentAdmin: admin, successMessage: '')),
    );
  }

  Future<void> _onCreateAdmin(CreateAdminEvent event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await createAdmin(
      username: event.username,
      password: event.password,
      email: event.email,
      fullName: event.fullName,
      phone: event.phone,
    );
    result.fold(
          (failure) {
        print('Failure in _onCreateAdmin: $failure, message: ${failure.message}');
        emit(AdminError(failure: failure));
      },
          (admin) {
        // Không thêm admin mới vào danh sách cục bộ, UI sẽ gọi FetchAllAdminsEvent để reload
        emit(const AdminCreated(successMessage: 'Tạo admin thành công'));
      },
    );
  }

  Future<void> _onUpdateAdmin(UpdateAdminEvent event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await updateAdmin(
      adminId: event.adminId,
      fullName: event.fullName,
      email: event.email,
      phone: event.phone,
    );
    result.fold(
          (failure) {
        print('Failure in _onUpdateAdmin: $failure, message: ${failure.message}');
        emit(AdminError(failure: failure));
      },
          (admin) {
        final updatedAdmins = _admins.map((a) => a.adminId == admin.adminId ? admin : a).toList();
        _admins = updatedAdmins;
        emit(AdminUpdated(currentAdmin: admin, successMessage: 'Cập nhật admin thành công'));
      },
    );
  }

  Future<void> _onDeleteAdmin(DeleteAdminEvent event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await deleteAdmin(event.adminId);
    result.fold(
          (failure) {
        print('Failure in _onDeleteAdmin: $failure, message: ${failure.message}');
        emit(AdminError(failure: failure));
      },
          (_) {
        final updatedAdmins = _admins.where((admin) => admin.adminId != event.adminId).toList();
        _admins = updatedAdmins;
        emit(AdminDeleted(admins: updatedAdmins, successMessage: 'Xóa admin thành công'));
      },
    );
  }

  Future<void> _onRequestPasswordReset(RequestPasswordResetEvent event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await requestPasswordReset(email: event.email);
    result.fold(
          (failure) {
        print('Failure in _onRequestPasswordReset: $failure, message: ${failure.message}');
        emit(AdminError(failure: failure));
      },
          (_) => emit(const AdminCreated(successMessage: 'Mã xác nhận đã được gửi qua email')),
    );
  }

  Future<void> _onConfirmResetPassword(ConfirmResetPasswordEvent event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await confirmResetPassword(
      email: event.email,
      newPassword: event.newPassword,
      code: event.code,
    );
    result.fold(
          (failure) {
        print('Failure in _onConfirmResetPassword: $failure, message: ${failure.message}');
        emit(AdminError(failure: failure));
      },
          (_) => emit(const AdminPasswordChanged(successMessage: 'Đặt lại mật khẩu thành công')),
    );
  }

  Future<void> _onChangePassword(ChangePasswordEvent event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await changePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );
    result.fold(
          (failure) {
        print('Failure in _onChangePassword: $failure, message: ${failure.message}');
        emit(AdminError(failure: failure));
      },
          (_) => emit(const AdminPasswordChanged(successMessage: 'Đổi mật khẩu thành công')),
    );
  }
}
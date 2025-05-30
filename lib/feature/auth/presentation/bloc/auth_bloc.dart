import 'package:bloc/bloc.dart';
import 'package:datn_web_admin/feature/admin/domain/usecase/get_admin_by_id.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:datn_web_admin/feature/admin/presentation/bloc/admin_bloc.dart';
import 'package:datn_web_admin/feature/admin/presentation/bloc/admin_event.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../../src/core/error/failures.dart';
import '../../../../src/core/network/api_client.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/usecases/auth_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login login;
  final Logout logout;
  final ForgotPassword forgotPassword;
  final ResetPassword resetPassword;
  final GetAdminById getAdminById;
  final ApiService apiService;

  AuthBloc({
    required this.login,
    required this.logout,
    required this.forgotPassword,
    required this.resetPassword,
    required this.getAdminById,
    required this.apiService,
  }) : super(const AuthState()) {
    on<AdminLoginSubmitted>(_onAdminLoginSubmitted);
    on<LogoutSubmitted>(_onLogoutSubmitted);
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<ResetPasswordSubmitted>(_onResetPasswordSubmitted);
    on<RefreshTokenRequested>(_onRefreshTokenRequested);
  }

  Future<void> _onAdminLoginSubmitted(AdminLoginSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    try {
      final result = await login.adminLogin(event.username, event.password);
      result.fold(
            (failure) {
          print('Login failed: ${failure.message}');
          emit(state.copyWith(
            isLoading: false,
            error: failure.message,
          ));
        },
            (authEntity) {
          print('Login successful: ${authEntity.accessToken}, Refresh: ${authEntity.refreshToken}, ID: ${authEntity.id}');
          emit(state.copyWith(
            isLoading: false,
            auth: authEntity,
            successMessage: 'Đăng nhập thành công',
          ));
          if (event.context != null) {
            event.context!.read<AdminBloc>().add(FetchCurrentAdminEvent(authEntity.id));
          }
        },
      );
    } catch (e) {
      print('Unexpected error during login: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'Lỗi không xác định: $e',
      ));
    }
  }

  Future<void> _onLogoutSubmitted(LogoutSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    try {
      final token = state.auth?.accessToken ?? apiService.token ?? '';
      final result = await logout(token);
      result.fold(
            (failure) => emit(state.copyWith(
          isLoading: false,
          error: failure.message,
        )),
            (_) => emit(const AuthState(
          successMessage: "Đăng xuất thành công",
          auth: null,
        )),
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e is ServerFailure ? e.message : "Lỗi không xác định.",
      ));
    }
  }

  Future<void> _onForgotPasswordSubmitted(ForgotPasswordSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    final result = await forgotPassword(event.email);
    result.fold(
          (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.message,
      )),
          (_) => emit(state.copyWith(
        isLoading: false,
        successMessage: 'Mã xác nhận đã được gửi qua email.',
      )),
    );
  }

  Future<void> _onResetPasswordSubmitted(ResetPasswordSubmitted event, Emitter<AuthState> emit) async {
    print('Submitting reset password with:');
    print('Email: ${event.email}');
    print('New Password: ${event.newPassword}');
    print('Code: ${event.code}');

    if (event.email.isEmpty) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Email không được để trống',
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    final result = await resetPassword(
      event.email,
      event.newPassword,
      event.code,
    );
    result.fold(
          (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.message,
      )),
          (_) => emit(state.copyWith(
        isLoading: false,
        successMessage: 'Đặt lại mật khẩu thành công.',
      )),
    );
  }

  Future<void> _onRefreshTokenRequested(RefreshTokenRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    try {
      final refreshed = await apiService.refreshAccessToken();
      if (refreshed) {
        final newToken = apiService.token;
        final newRefreshToken = apiService.refreshToken;
        final decodedToken = JwtDecoder.decode(newToken!);
        final userId = decodedToken['sub'] as String?;
        final type = decodedToken['type'] as String? ?? 'UNKNOWN';
        if (userId == null) {
          throw ServerFailure('Không thể trích xuất ID từ token');
        }
        emit(state.copyWith(
          isLoading: false,
          auth: AuthEntity(
            id: int.parse(userId),
            accessToken: newToken,
            refreshToken: newRefreshToken!,
            type: type,
          ),
          successMessage: 'Làm mới token thành công',
        ));
      } else {
        await apiService.clearToken();
        emit(state.copyWith(
          isLoading: false,
          auth: null,
          error: 'Không thể làm mới token. Vui lòng đăng nhập lại.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Lỗi làm mới token: $e',
      ));
    }
  }
}
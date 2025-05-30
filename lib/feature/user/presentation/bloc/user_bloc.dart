import 'package:bloc/bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/create_user.dart';
import '../../domain/usecases/delete_user.dart';
import '../../domain/usecases/get_all_users.dart';
import '../../domain/usecases/update_user.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetAllUsers getAllUsers;
  final CreateUser createUser;
  final UpdateUser updateUser;
  final DeleteUser deleteUser;

  UserBloc({
    required this.getAllUsers,
    required this.createUser,
    required this.updateUser,
    required this.deleteUser,
  }) : super(const UserState()) {
    on<FetchUsersEvent>(_onFetchUsers);
    on<CreateUserEvent>(_onCreateUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<DeleteUserEvent>(_onDeleteUser);
  }

  Future<void> _onFetchUsers(FetchUsersEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    try {
      final result = await getAllUsers(
        page: event.page,
        limit: event.limit,
        email: event.email,
        fullname: event.fullname,
        phone: event.phone,
        className: event.className,
      );
      result.fold(
            (failure) => emit(state.copyWith(
          isLoading: false,
          error: failure.message,
          successMessage: null,
        )),
            (users) => emit(state.copyWith(
          isLoading: false,
          users: users,
          successMessage: null,
        )),
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Lỗi không xác định: $e',
        successMessage: null,
      ));
    }
  }

  Future<void> _onCreateUser(CreateUserEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    try {
      final result = await createUser(
        email: event.email,
        fullname: event.fullname,
        phone: event.phone,
      );
      result.fold(
            (failure) => emit(state.copyWith(
          isLoading: false,
          error: failure.message,
          successMessage: null,
        )),
            (user) {
          final updatedUsers = List<UserEntity>.from(state.users)..add(user);
          emit(state.copyWith(
            isLoading: false,
            users: updatedUsers,
            successMessage: 'Tạo người dùng thành công',
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Lỗi không xác định: $e',
        successMessage: null,
      ));
    }
  }

  Future<void> _onUpdateUser(UpdateUserEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    try {
      final result = await updateUser(
        userId: event.userId,
        fullname: event.fullname,
        email: event.email,
        phone: event.phone,
        cccd: event.cccd,
        dateOfBirth: event.dateOfBirth,
        className: event.className,
      );
      result.fold(
            (failure) => emit(state.copyWith(
          isLoading: false,
          error: failure.message,
          successMessage: null,
        )),
            (user) {
          final updatedUsers = state.users.map((u) {
            if (u.userId == event.userId) {
              return user;
            }
            return u;
          }).toList();
          print('UpdateUser successful for user ID: ${event.userId}');
          emit(state.copyWith(
            users: updatedUsers,
            isLoading: false,
            successMessage: 'Cập nhật người dùng thành công!',
          ));
          Future.delayed(const Duration(milliseconds: 500), () {
            add(FetchUsersEvent(page: 1, limit: 1000));
          });
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Lỗi không xác định: $e',
        successMessage: null,
      ));
    }
  }

  Future<void> _onDeleteUser(DeleteUserEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    try {
      final result = await deleteUser(event.userId);
      result.fold(
            (failure) => emit(state.copyWith(
          isLoading: false,
          error: failure.message,
          successMessage: null,
        )),
            (_) {
          final updatedUsers = state.users.where((u) => u.userId != event.userId).toList();
          emit(state.copyWith(
            isLoading: false,
            users: updatedUsers,
            successMessage: 'Xóa người dùng thành công',
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Lỗi không xác định: $e',
        successMessage: null,
      ));
    }
  }
}
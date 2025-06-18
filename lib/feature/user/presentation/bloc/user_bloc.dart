import 'package:bloc/bloc.dart';
import 'package:datn_web_admin/feature/user/domain/usecases/user_usecase.dart';
import '../../domain/entities/user_entity.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetAllUsers getAllUsers;
  final CreateUser createUser;
  final UpdateUser updateUser;
  final DeleteUser deleteUser;

  // Cache for loaded pages
  final Map<int, List<UserEntity>> _pageCache = {};
  int _currentPage = 1;
  int _totalItems = 0;

  UserBloc({
    required this.getAllUsers,
    required this.createUser,
    required this.updateUser,
    required this.deleteUser,
  }) : super(UserInitial()) {
    on<FetchUsersEvent>(_onFetchUsers);
    on<CreateUserEvent>(_onCreateUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<DeleteUserEvent>(_onDeleteUser);
  }

  Future<void> _onFetchUsers(FetchUsersEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());

    // Check cache first
    if (_pageCache.containsKey(event.page) && event.page != _currentPage) {
      emit(UserLoaded(users: _pageCache[event.page]!, totalItems: _totalItems));
      return;
    }

    try {
      final result = await getAllUsers(
        page: event.page,
        limit: event.limit,
        keyword: event.keyword, // Thêm dòng này
        email: event.email,
        fullname: event.fullname,
        phone: event.phone,
        className: event.className,
      );
      result.fold(
        (failure) => emit(UserError(message: failure.message)),
        (data) {
          final (users, total) = data;
          _currentPage = event.page;
          _totalItems = total;
          _pageCache[event.page] = users; // Cache the page
          emit(UserLoaded(users: users, totalItems: total));
        },
      );
    } catch (e) {
      emit(UserError(message: 'Lỗi không xác định: $e'));
    }
  }

  Future<void> _onCreateUser(CreateUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final result = await createUser(
        email: event.email,
        fullname: event.fullname,
        phone: event.phone,
      );
      result.fold(
        (failure) => emit(UserError(message: failure.message)),
        (user) {
          emit(UserCreated(user: user));
          // Clear cache and re-fetch current page
          _pageCache.clear();
          add(FetchUsersEvent(page: _currentPage, limit: 10));
        },
      );
    } catch (e) {
      emit(UserError(message: 'Lỗi không xác định: $e'));
    }
  }

  Future<void> _onUpdateUser(UpdateUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
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
        (failure) => emit(UserError(message: failure.message)),
        (user) {
          emit(UserUpdated(user: user));
          // Clear cache and re-fetch current page
          _pageCache.clear();
          add(FetchUsersEvent(page: _currentPage, limit: 10));
        },
      );
    } catch (e) {
      emit(UserError(message: 'Lỗi không xác định: $e'));
    }
  }

  Future<void> _onDeleteUser(DeleteUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final result = await deleteUser(event.userId);
      result.fold(
        (failure) => emit(UserError(message: failure.message)),
        (_) {
          emit(UserDeleted(userId: event.userId));
          // Clear cache and re-fetch current page
          _pageCache.clear();
          add(FetchUsersEvent(page: _currentPage, limit: 10));
        },
      );
    } catch (e) {
      emit(UserError(message: 'Lỗi không xác định: $e'));
    }
  }
}
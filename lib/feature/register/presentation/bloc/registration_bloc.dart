import 'package:datn_web_admin/feature/auth/presentation/bloc/auth_state.dart';
import 'package:datn_web_admin/feature/register/presentation/bloc/registration_event.dart';
import 'package:datn_web_admin/feature/register/presentation/bloc/registration_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecase/registration_usecase.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final GetAllRegistrations getAllRegistrations;
  final GetRegistrationById getRegistrationById;
  final UpdateRegistrationStatus updateRegistrationStatus;
  final SetMeetingDatetime setMeetingDatetime;
  final DeleteRegistrationsBatch deleteRegistrationsBatch;

  RegistrationBloc({
    required this.getAllRegistrations,
    required this.getRegistrationById,
    required this.updateRegistrationStatus,
    required this.setMeetingDatetime,
    required this.deleteRegistrationsBatch,
  }) : super(RegistrationInitial()) {
    on<FetchRegistrations>(_onFetchRegistrations);
    on<FetchRegistrationById>(_onFetchRegistrationById);
    on<UpdateRegistrationStatusEvent>(_onUpdateRegistrationStatus);
    on<SetMeetingDatetimeEvent>(_onSetMeetingDatetime);
    on<DeleteRegistrationsBatchEvent>(_onDeleteRegistrationsBatch);
  }

  Future<void> _onFetchRegistrations(
    FetchRegistrations event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(RegistrationLoading());
    try {
      final result = await getAllRegistrations(
        page: event.page,
        limit: event.limit,
        status: event.status,
        nameStudent: event.nameStudent,
      );
      result.fold(
        (failure) {
          print('RegistrationBloc: Error fetching registrations: ${failure.message}');
          emit(RegistrationError(failure.message));
        },
        (tuple) {
          print('RegistrationBloc: Successfully fetched ${tuple.$1.length} registrations');
          emit(RegistrationsLoaded(
            registrations: tuple.$1,
            total: tuple.$2,
          ));
        },
      );
    } on AuthFailure catch (e) {
      print('RegistrationBloc: AuthFailure while fetching registrations: $e');
      emit(RegistrationError('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'));
    } catch (e) {
      print('RegistrationBloc: Unexpected error while fetching registrations: $e');
      emit(RegistrationError('Lỗi không xác định: $e'));
    }
  }

  Future<void> _onFetchRegistrationById(
    FetchRegistrationById event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(RegistrationLoading());
    try {
      final result = await getRegistrationById(event.id);
      result.fold(
        (failure) {
          print('RegistrationBloc: Error fetching registration by ID: ${failure.message}');
          emit(RegistrationError(failure.message));
        },
        (registration) {
          print('RegistrationBloc: Successfully fetched registration: ${registration.registrationId}');
          emit(RegistrationLoaded(registration));
        },
      );
    } on AuthFailure catch (e) {
      print('RegistrationBloc: AuthFailure while fetching registration by ID: $e');
      emit(RegistrationError('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'));
    } catch (e) {
      print('RegistrationBloc: Unexpected error while fetching registration by ID: $e');
      emit(RegistrationError('Lỗi không xác định: $e'));
    }
  }

  Future<void> _onUpdateRegistrationStatus(
    UpdateRegistrationStatusEvent event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(RegistrationLoading());
    try {
      final result = await updateRegistrationStatus(
        id: event.id,
        status: event.status,
        rejectionReason: event.rejectionReason,
      );
      result.fold(
        (failure) {
          print('RegistrationBloc: Error updating registration status: ${failure.message}');
          emit(RegistrationError(failure.message));
        },
        (registration) {
          print('RegistrationBloc: Successfully updated registration: ${registration.registrationId}');
          emit(RegistrationUpdated(registration));
        },
      );
    } on AuthFailure catch (e) {
      print('RegistrationBloc: AuthFailure while updating registration status: $e');
      emit(RegistrationError('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'));
    } catch (e) {
      print('RegistrationBloc: Unexpected error while updating registration status: $e');
      emit(RegistrationError('Lỗi không xác định: $e'));
    }
  }

  Future<void> _onSetMeetingDatetime(
    SetMeetingDatetimeEvent event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(RegistrationLoading());
    try {
      final result = await setMeetingDatetime(
        id: event.id,
        meetingDatetime: event.meetingDatetime,
        meetingLocation: event.meetingLocation,
      );
      result.fold(
        (failure) {
          print('RegistrationBloc: Error setting meeting datetime: ${failure.message}');
          emit(RegistrationError(failure.message));
        },
        (registration) {
          print('RegistrationBloc: Successfully set meeting datetime for registration: ${registration.registrationId}');
          emit(RegistrationUpdated(registration));
        },
      );
    } on AuthFailure catch (e) {
      print('RegistrationBloc: AuthFailure while setting meeting datetime: $e');
      emit(RegistrationError('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'));
    } catch (e) {
      print('RegistrationBloc: Unexpected error while setting meeting datetime: $e');
      emit(RegistrationError('Lỗi không xác định: $e'));
    }
  }

  Future<void> _onDeleteRegistrationsBatch(
    DeleteRegistrationsBatchEvent event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(RegistrationLoading());
    try {
      final result = await deleteRegistrationsBatch(event.registrationIds);
      result.fold(
        (failure) {
          print('RegistrationBloc: Error deleting registrations batch: ${failure.message}');
          emit(RegistrationError(failure.message));
        },
        (response) {
          print('RegistrationBloc: Successfully deleted registrations batch: ${response['deleted_ids']}');
          emit(RegistrationsDeleted(
            deletedIds: response['deleted_ids'] as List<int>,
            message: response['message'] as String?,
          ));
        },
      );
    } on AuthFailure catch (e) {
      print('RegistrationBloc: AuthFailure while deleting registrations batch: $e');
      emit(RegistrationError('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'));
    } catch (e) {
      print('RegistrationBloc: Unexpected error while deleting registrations batch: $e');
      emit(RegistrationError('Lỗi không xác định: $e'));
    }
  }
}
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:datn_web_admin/feature/register/presentation/bloc/registration_event.dart';
import 'package:datn_web_admin/feature/register/presentation/bloc/registration_state.dart';

import '../../domain/usecase/delete_registration.dart';
import '../../domain/usecase/get_all_registration.dart';
import '../../domain/usecase/get_registration_by_id.dart';
import '../../domain/usecase/set_meeting_datetime.dart';
import '../../domain/usecase/update_registration.dart';

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

  Future<void> _onFetchRegistrations(FetchRegistrations event, Emitter<RegistrationState> emit) async {
    emit(RegistrationLoading());
    final result = await getAllRegistrations(
      page: event.page,
      limit: event.limit,
      status: event.status,
      roomId: event.roomId,
      nameStudent: event.nameStudent,
      meetingDatetime: event.meetingDatetime,
    );
    result.fold(
          (failure) => emit(RegistrationError(failure.message)),
          (registrations) => emit(RegistrationsLoaded(
        registrations: registrations,
        total: registrations.length, // Cần lấy từ API nếu có
        pages: 1, // Cần lấy từ API nếu có
        currentPage: event.page,
      )),
    );
  }

  Future<void> _onFetchRegistrationById(FetchRegistrationById event, Emitter<RegistrationState> emit) async {
    emit(RegistrationLoading());
    final result = await getRegistrationById(event.id);
    result.fold(
          (failure) => emit(RegistrationError(failure.message)),
          (registration) => emit(RegistrationDetailLoaded(registration)),
    );
  }

  Future<void> _onUpdateRegistrationStatus(UpdateRegistrationStatusEvent event, Emitter<RegistrationState> emit) async {
    emit(RegistrationLoading());
    final result = await updateRegistrationStatus(
      id: event.id,
      status: event.status,
      rejectionReason: event.rejectionReason,
    );
    result.fold(
          (failure) => emit(RegistrationError(failure.message)),
          (registration) => emit(RegistrationUpdated(registration)),
    );
  }

  Future<void> _onSetMeetingDatetime(SetMeetingDatetimeEvent event, Emitter<RegistrationState> emit) async {
    emit(RegistrationLoading());
    final result = await setMeetingDatetime(
      id: event.id,
      meetingDatetime: event.meetingDatetime,
      meetingLocation: event.meetingLocation,
    );
    result.fold(
          (failure) => emit(RegistrationError(failure.message)),
          (registration) => emit(RegistrationUpdated(registration)),
    );
  }

  Future<void> _onDeleteRegistrationsBatch(DeleteRegistrationsBatchEvent event, Emitter<RegistrationState> emit) async {
    emit(RegistrationLoading());
    final result = await deleteRegistrationsBatch(event.registrationIds);
    result.fold(
          (failure) => emit(RegistrationError(failure.message)),
          (response) => emit(RegistrationsDeleted(
        deletedIds: response['deleted_ids'] as List<int>,
        errors: response['errors'] as List<Map<String, dynamic>>,
        message: response['message'] as String?,
      )),
    );
  }
}
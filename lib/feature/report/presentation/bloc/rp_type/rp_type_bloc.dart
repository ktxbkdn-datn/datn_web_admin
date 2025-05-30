// lib/src/features/report/presentations/bloc_rt/report_type_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:datn_web_admin/feature/report/presentation/bloc/rp_type/rp_type_event.dart';
import 'package:datn_web_admin/feature/report/presentation/bloc/rp_type/rp_type_state.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';

import '../../../domain/entities/report_type_entity.dart';
import '../../../domain/usecase/rp_type/create_report_type.dart';
import '../../../domain/usecase/rp_type/delete_report_type.dart';
import '../../../domain/usecase/rp_type/get_all_report_types.dart';
import '../../../domain/usecase/rp_type/update_report_type.dart';


class ReportTypeBloc extends Bloc<ReportTypeEvent, ReportTypeState> {
  final GetAllReportTypes getAllReportTypes;
  final CreateReportType createReportType;
  final UpdateReportType updateReportType;
  final DeleteReportType deleteReportType;
  final List<ReportTypeEntity> _reportTypeCache = [];

  ReportTypeBloc({
    required this.getAllReportTypes,
    required this.createReportType,
    required this.updateReportType,
    required this.deleteReportType,
  }) : super(ReportTypeInitial()) {
    on<GetAllReportTypesEvent>(_onGetAllReportTypes);
    on<CreateReportTypeEvent>(_onCreateReportType);
    on<UpdateReportTypeEvent>(_onUpdateReportType);
    on<DeleteReportTypeEvent>(_onDeleteReportType);
    on<ResetReportTypeStateEvent>(_onResetReportTypeState);
  }

  Future<void> _onGetAllReportTypes(GetAllReportTypesEvent event, Emitter<ReportTypeState> emit) async {
    emit(ReportTypeLoading());
    final result = await getAllReportTypes(page: event.page, limit: event.limit);
    result.fold(
          (failure) {
        if (failure.message.contains('Không tìm thấy loại báo cáo')) {
          _reportTypeCache.clear();
          emit(ReportTypesLoaded(reportTypes: []));
        } else {
          emit(ReportTypeError(message: failure.message));
        }
      },
          (reportTypeList) {
        _reportTypeCache.clear();
        _reportTypeCache.addAll(reportTypeList);
        emit(ReportTypesLoaded(reportTypes: reportTypeList));
      },
    );
  }

  Future<void> _onCreateReportType(CreateReportTypeEvent event, Emitter<ReportTypeState> emit) async {
    emit(ReportTypeLoading());
    final result = await createReportType(event.name);
    result.fold(
          (failure) {
        emit(ReportTypeError(message: failure.message));
      },
          (reportType) {
        _reportTypeCache.clear();
        add(const GetAllReportTypesEvent());
      },
    );
  }

  Future<void> _onUpdateReportType(UpdateReportTypeEvent event, Emitter<ReportTypeState> emit) async {
    emit(ReportTypeLoading());
    final result = await updateReportType(reportTypeId: event.reportTypeId, name: event.name);
    result.fold(
          (failure) {
        emit(ReportTypeError(message: failure.message));
      },
          (reportType) {
        _reportTypeCache.clear();
        add(const GetAllReportTypesEvent());
      },
    );
  }

  Future<void> _onDeleteReportType(DeleteReportTypeEvent event, Emitter<ReportTypeState> emit) async {
    emit(ReportTypeLoading());
    final result = await deleteReportType(event.reportTypeId);
    result.fold(
          (failure) {
        emit(ReportTypeError(message: failure.message));
      },
          (_) {
        _reportTypeCache.clear();
        add(const GetAllReportTypesEvent());
      },
    );
  }

  Future<void> _onResetReportTypeState(ResetReportTypeStateEvent event, Emitter<ReportTypeState> emit) async {
    emit(ReportTypeInitial());
    _reportTypeCache.clear();
  }
}
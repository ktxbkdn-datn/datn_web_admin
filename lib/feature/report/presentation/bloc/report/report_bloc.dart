// lib/src/features/report/presentations/bloc_r/report_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';

import '../../../domain/entities/report_entity.dart';
import '../../../domain/usecase/report/delete_report.dart';
import '../../../domain/usecase/report/get_all_reports.dart';
import '../../../domain/usecase/report/get_report_by_id.dart';
import '../../../domain/usecase/report/update_report.dart';
import '../../../domain/usecase/report/update_report_status.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final GetAllReports getAllReports;
  final GetReportById getReportById;
  final UpdateReport updateReport;
  final UpdateReportStatus updateReportStatus;
  final DeleteReport deleteReport;
  final Map<int, ReportEntity> _reportCache = {};
  final List<ReportEntity> _reportListCache = [];

  ReportBloc({
    required this.getAllReports,
    required this.getReportById,
    required this.updateReport,
    required this.updateReportStatus,
    required this.deleteReport,
  }) : super(ReportInitial()) {
    on<GetAllReportsEvent>(_onGetAllReports);
    on<GetReportByIdEvent>(_onGetReportById);
    on<UpdateReportEvent>(_onUpdateReport);
    on<UpdateReportStatusEvent>(_onUpdateReportStatus);
    on<DeleteReportEvent>(_onDeleteReport);
    on<ResetReportStateEvent>(_onResetReportState);
  }

  Future<void> _onGetAllReports(GetAllReportsEvent event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    final result = await getAllReports(
      page: event.page,
      limit: event.limit,
      userId: event.userId,
      roomId: event.roomId,
      status: event.status,
    );
    result.fold(
          (failure) {
        if (failure.message.contains('Trang không tồn tại')) {
          _reportListCache.clear();
          emit(ReportsLoaded(reports: []));
        } else {
          emit(ReportError(message: failure.message));
        }
      },
          (reportList) {
        _reportListCache.clear();
        _reportListCache.addAll(reportList);
        emit(ReportsLoaded(reports: reportList));
      },
    );
  }

  Future<void> _onGetReportById(GetReportByIdEvent event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    final result = await getReportById(event.reportId);
    result.fold(
          (failure) {
        emit(ReportError(message: failure.message));
      },
          (report) {
        _reportCache[event.reportId] = report;
        emit(ReportLoaded(report: report));
      },
    );
  }

  Future<void> _onUpdateReport(UpdateReportEvent event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    final result = await updateReport(
      reportId: event.reportId,
      roomId: event.roomId,
      reportTypeId: event.reportTypeId,
      description: event.description,
      status: event.status,
    );
    result.fold(
          (failure) {
        emit(ReportError(message: failure.message));
      },
          (report) {
        _reportCache[event.reportId] = report;
        emit(ReportUpdated(report: report));
        add(GetAllReportsEvent());
      },
    );
  }

  Future<void> _onUpdateReportStatus(UpdateReportStatusEvent event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    final result = await updateReportStatus(
      reportId: event.reportId,
      status: event.status,
    );
    result.fold(
          (failure) {
        emit(ReportError(message: failure.message));
      },
          (report) {
        _reportCache[event.reportId] = report;
        emit(ReportStatusUpdated(report: report));
        add(GetAllReportsEvent());
      },
    );
  }

  Future<void> _onDeleteReport(DeleteReportEvent event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    final result = await deleteReport(event.reportId);
    result.fold(
          (failure) {
        emit(ReportError(message: failure.message));
      },
          (_) {
        _reportCache.remove(event.reportId);
        add(GetAllReportsEvent());
      },
    );
  }

  Future<void> _onResetReportState(ResetReportStateEvent event, Emitter<ReportState> emit) async {
    emit(ReportInitial());
    _reportCache.clear();
    _reportListCache.clear();
  }
}
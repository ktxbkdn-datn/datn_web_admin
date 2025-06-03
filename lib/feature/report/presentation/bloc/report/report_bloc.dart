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
  final Map<int, List<ReportEntity>> _pageCache = {}; // Cache for 5 recent pages
  static const int _maxCachedPages = 5;

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

  void _managePageCache(int page, List<ReportEntity> reports) {
    _pageCache[page] = reports;
    if (_pageCache.length > _maxCachedPages) {
      final oldestPage = _pageCache.keys.reduce((a, b) => a < b ? a : b);
      _pageCache.remove(oldestPage);
    }
  }

  void _clearPageCache() {
    _pageCache.clear();
  }

  Future<void> _onGetAllReports(GetAllReportsEvent event, Emitter<ReportState> emit) async {
    if (_pageCache.containsKey(event.page)) {
      emit(ReportsLoaded(reports: _pageCache[event.page]!, totalItems: 0)); // TotalItems handled by UI
      return;
    }

    emit(ReportLoading());
    final result = await getAllReports(
      page: event.page,
      limit: event.limit,
      userId: event.userId,
      roomId: event.roomId,
      status: event.status,
      reportTypeId: event.reportTypeId,
      searchQuery: event.searchQuery,
    );
    result.fold(
      (failure) {
        if (failure.message.contains('Trang không tồn tại')) {
          _clearPageCache();
          emit(ReportsLoaded(reports: [], totalItems: 0));
        } else {
          emit(ReportError(message: failure.message));
        }
      },
      (data) {
        _managePageCache(event.page, data.$1);
        emit(ReportsLoaded(reports: data.$1, totalItems: data.$2));
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
        _clearPageCache(); // Clear cache after CRUD
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
        _clearPageCache(); // Clear cache after CRUD
        emit(ReportStatusUpdated(report: report));
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
        _clearPageCache(); // Clear cache after CRUD
        emit(ReportDeleted(reportId: event.reportId));
      },
    );
  }

  Future<void> _onResetReportState(ResetReportStateEvent event, Emitter<ReportState> emit) async {
    emit(ReportInitial());
    _reportCache.clear();
    _clearPageCache();
  }
}
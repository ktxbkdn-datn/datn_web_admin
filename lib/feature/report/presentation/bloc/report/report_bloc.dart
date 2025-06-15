import 'package:bloc/bloc.dart';
import 'package:datn_web_admin/feature/auth/presentation/bloc/auth_state.dart';
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
  final Map<String, List<ReportEntity>> _pageCache = {};
  static const int _maxCachedPages = 5;
  int _lastTotalItems = 0; // Thêm biến này

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
  // Generate a unique cache key based on all filter parameters
  String _generateCacheKey(GetAllReportsEvent event) {
    return 'page=${event.page}:limit=${event.limit}:userId=${event.userId ?? "null"}:roomId=${event.roomId ?? "null"}:status=${event.status ?? "null"}:reportTypeId=${event.reportTypeId ?? "null"}:search=${event.searchQuery ?? "null"}';
  }
  void _managePageCache(String cacheKey, List<ReportEntity> reports) {
    print('ReportBloc: Caching with key $cacheKey with ${reports.length} reports');
    _pageCache[cacheKey] = List.from(reports); // Create a copy to avoid mutating the original list
    if (_pageCache.length > _maxCachedPages) {
      // Get all keys and find the oldest one to remove
      final keys = _pageCache.keys.toList();
      if (keys.isNotEmpty) {
        final oldestKey = keys.first; // Simple approach - remove first key
        _pageCache.remove(oldestKey);
        print('ReportBloc: Removed oldest page cache: $oldestKey');
      }
    }
  }

  void _clearPageCache() {
    print('ReportBloc: Clearing page cache');
    _pageCache.clear();
  }

  Future<void> _onGetAllReports(GetAllReportsEvent event, Emitter<ReportState> emit) async {
    print('ReportBloc: Handling GetAllReportsEvent: page=${event.page}, limit=${event.limit}, userId=${event.userId}, roomId=${event.roomId}, status=${event.status}, reportTypeId=${event.reportTypeId}, searchQuery=${event.searchQuery}');

    final cacheKey = _generateCacheKey(event);
    
    // Check cache first
    if (_pageCache.containsKey(cacheKey)) {
      print('ReportBloc: Serving reports from cache for key $cacheKey');
      emit(ReportsLoaded(reports: List.from(_pageCache[cacheKey]!), totalItems: _lastTotalItems));
      return;
    }

    emit(ReportLoading());
    try {
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
            print('ReportBloc: Page does not exist, clearing cache and emitting empty list');
            _clearPageCache();
            emit(ReportsLoaded(reports: [], totalItems: 0));
          } else {
            print('ReportBloc: Error fetching reports: ${failure.message}');
            emit(ReportError(message: failure.message));
          }
        },
        (data) {
          print('ReportBloc: Successfully fetched ${data.$1.length} reports, totalItems: ${data.$2}');
          _managePageCache(cacheKey, data.$1);
          _lastTotalItems = data.$2; // Cập nhật lại biến này
          emit(ReportsLoaded(reports: List.from(data.$1), totalItems: data.$2));
        },
      );
    } on AuthFailure catch (e) {
      print('ReportBloc: AuthFailure while fetching reports: $e');
      emit(ReportError(message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'));
    } catch (e) {
      print('ReportBloc: Unexpected error while fetching reports: $e');
      emit(ReportError(message: 'Lỗi không xác định: $e'));
    }
  }

  Future<void> _onGetReportById(GetReportByIdEvent event, Emitter<ReportState> emit) async {
    print('ReportBloc: Handling GetReportByIdEvent: reportId=${event.reportId}');

    emit(ReportLoading());
    try {
      final result = await getReportById(event.reportId);
      result.fold(
        (failure) {
          print('ReportBloc: Error fetching report by ID: ${failure.message}');
          emit(ReportError(message: failure.message));
        },
        (report) {
          print('ReportBloc: Successfully fetched report: ${report.reportId}');
          _reportCache[event.reportId] = report;
          emit(ReportLoaded(report: report));
        },
      );
    } on AuthFailure catch (e) {
      print('ReportBloc: AuthFailure while fetching report by ID: $e');
      emit(ReportError(message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'));
    } catch (e) {
      print('ReportBloc: Unexpected error while fetching report by ID: $e');
      emit(ReportError(message: 'Lỗi không xác định: $e'));
    }
  }

  Future<void> _onUpdateReport(UpdateReportEvent event, Emitter<ReportState> emit) async {
    print('ReportBloc: Handling UpdateReportEvent: reportId=${event.reportId}, roomId=${event.roomId}, reportTypeId=${event.reportTypeId}, description=${event.description}, status=${event.status}');

    emit(ReportLoading());
    try {
      final result = await updateReport(
        reportId: event.reportId,
        roomId: event.roomId,
        reportTypeId: event.reportTypeId,
        description: event.description,
        status: event.status,
      );
      result.fold(
        (failure) {
          print('ReportBloc: Error updating report: ${failure.message}');
          emit(ReportError(message: failure.message));
        },
        (report) {
          print('ReportBloc: Successfully updated report: ${report.reportId}');
          _reportCache[event.reportId] = report;
          _clearPageCache(); // Clear cache after CRUD
          emit(ReportUpdated(report: report));
          add(const GetAllReportsEvent()); // Refresh the list
        },
      );
    } on AuthFailure catch (e) {
      print('ReportBloc: AuthFailure while updating report: $e');
      emit(ReportError(message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'));
    } catch (e) {
      print('ReportBloc: Unexpected error while updating report: $e');
      emit(ReportError(message: 'Lỗi không xác định: $e'));
    }
  }

  Future<void> _onUpdateReportStatus(UpdateReportStatusEvent event, Emitter<ReportState> emit) async {
    print('ReportBloc: Handling UpdateReportStatusEvent: reportId=${event.reportId}, status=${event.status}');

    emit(ReportLoading());
    try {
      final result = await updateReportStatus(
        reportId: event.reportId,
        status: event.status,
      );
      result.fold(
        (failure) {
          print('ReportBloc: Error updating report status: ${failure.message}');
          emit(ReportError(message: failure.message));
        },
        (report) {
          print('ReportBloc: Successfully updated report status: ${report.reportId}');
          _reportCache[event.reportId] = report;
          _clearPageCache(); // Clear cache after CRUD
          emit(ReportStatusUpdated(report: report));
        },
      );
    } on AuthFailure catch (e) {
      print('ReportBloc: AuthFailure while updating report status: $e');
      emit(ReportError(message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'));
    } catch (e) {
      print('ReportBloc: Unexpected error while updating report status: $e');
      emit(ReportError(message: 'Lỗi không xác định: $e'));
    }
  }

  Future<void> _onDeleteReport(DeleteReportEvent event, Emitter<ReportState> emit) async {
    print('ReportBloc: Handling DeleteReportEvent: reportId=${event.reportId}');

    emit(ReportLoading());
    try {
      final result = await deleteReport(event.reportId);
      result.fold(
        (failure) {
          print('ReportBloc: Error deleting report: ${failure.message}');
          emit(ReportError(message: failure.message));
        },
        (_) {
          print('ReportBloc: Successfully deleted report: ${event.reportId}');
          _reportCache.remove(event.reportId);
          _clearPageCache(); // Clear cache after CRUD
          emit(ReportDeleted(reportId: event.reportId));
        },
      );
    } on AuthFailure catch (e) {
      print('ReportBloc: AuthFailure while deleting report: $e');
      emit(ReportError(message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'));
    } catch (e) {
      print('ReportBloc: Unexpected error while deleting report: $e');
      emit(ReportError(message: 'Lỗi không xác định: $e'));
    }
  }

  Future<void> _onResetReportState(ResetReportStateEvent event, Emitter<ReportState> emit) async {
    print('ReportBloc: Handling ResetReportStateEvent');
    emit(ReportInitial());
    _reportCache.clear();
    _clearPageCache();
  }
}
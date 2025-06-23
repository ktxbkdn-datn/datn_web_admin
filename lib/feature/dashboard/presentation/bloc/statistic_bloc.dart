import 'package:datn_web_admin/feature/dashboard/domain/entities/room_status.dart';
import 'package:datn_web_admin/src/core/error/failures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../domain/usecase/statistic_usecase.dart' as usecase;
import 'statistic_event.dart';
import 'statistic_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final usecase.GetMonthlyConsumption getMonthlyConsumption;
  final usecase.SaveConsumption saveConsumption;
  final usecase.LoadCachedConsumption loadCachedConsumption;
  final usecase.GetRoomStatusStats getRoomStatusStats;
  final usecase.GetRoomStatusSummary getRoomStatusSummary;
  final usecase.GetUserSummary getUserSummary;
  final usecase.TriggerManualSnapshot triggerManualSnapshot;
  final usecase.GetRoomCapacityStats getRoomCapacityStats;
  final usecase.GetContractStats getContractStats;
  final usecase.GetUserStats getUserStats;
  final usecase.GetUserMonthlyStats getUserMonthlyStats;
  final usecase.GetOccupancyRateStats getOccupancyRateStats;
  final usecase.GetReportStats getReportStats;
  final usecase.GetRoomFillRateStats getRoomFillRateStats;
  final usecase.SaveRoomFillRate saveRoomFillRate;
  final usecase.LoadCachedRoomFillRate loadCachedRoomFillRate;
  final usecase.LoadCachedRoomStats loadCachedRoomStats;
  final usecase.LoadCachedUserMonthlyStats loadCachedUserMonthlyStats;
  final usecase.LoadCachedReportStats loadCachedReportStats;
  final usecase.LoadCachedUserStats loadCachedUserStats;

  StatisticsBloc({
    required this.getMonthlyConsumption,
    required this.saveConsumption,
    required this.loadCachedConsumption,
    required this.getRoomStatusStats,
    required this.getRoomStatusSummary,
    required this.getUserSummary,
    required this.triggerManualSnapshot,
    required this.getRoomCapacityStats,
    required this.getContractStats,
    required this.getUserStats,
    required this.getUserMonthlyStats,
    required this.getOccupancyRateStats,
    required this.getReportStats,
    required this.getRoomFillRateStats,
    required this.saveRoomFillRate,
    required this.loadCachedRoomFillRate,
    required this.loadCachedRoomStats,
    required this.loadCachedUserMonthlyStats,
    required this.loadCachedReportStats,
    required this.loadCachedUserStats,
  }) : super(StatisticsInitial()) {
    on<FetchMonthlyConsumption>(_onFetchMonthlyConsumption);
    on<LoadCachedConsumption>(_onLoadCachedConsumption);
    on<FetchRoomStatusStats>(_onFetchRoomStatusStats);
    on<FetchRoomStatusSummary>(_onFetchRoomStatusSummary);
    on<FetchUserSummary>(_onFetchUserSummary);
    on<TriggerManualSnapshot>(_onTriggerManualSnapshot);
    on<FetchRoomCapacityStats>(_onFetchRoomCapacityStats);
    on<FetchContractStats>(_onFetchContractStats);
    on<FetchUserStats>(_onFetchUserStats);
    on<FetchUserMonthlyStats>(_onFetchUserMonthlyStats);
    on<FetchOccupancyRateStats>(_onFetchOccupancyRateStats);
    on<FetchReportStats>(_onFetchReportStats);
    on<FetchRoomFillRateStats>(_onFetchRoomFillRateStats);
    on<LoadCachedRoomFillRateStats>(_onLoadCachedRoomFillRateStats);
    on<LoadCachedRoomStatsEvent>(_onLoadCachedRoomStats);
    on<LoadCachedUserMonthlyStatsEvent>(_onLoadCachedUserMonthlyStats);
    on<LoadCachedReportStatsEvent>(_onLoadCachedReportStats);
    on<LoadCachedUserStatsEvent>(_onLoadCachedUserStats);
  }

  Future<void> _handleRequest<T>(
    Future<Either<Failure, T>> Function() request,
    Emitter<StatisticsState> emit,
    StatisticsState Function(T) successState,
    String requestType,
  ) async {
    emit(PartialLoading(requestType: requestType));
    try {
      final result = await request();
      result.fold(
        (failure) => emit(StatisticsError(
          message: failure.message,
          errorType: failure is ServerFailure ? ErrorType.server : ErrorType.network,
        )),
        (data) => emit(successState(data)),
      );
    } catch (e) {
      emit(StatisticsError(
        message: 'Unexpected error: $e',
        errorType: ErrorType.unknown,
      ));
    }
  }

  Future<void> _onFetchMonthlyConsumption(FetchMonthlyConsumption event, Emitter<StatisticsState> emit) async {
    await _handleRequest(
      () => getMonthlyConsumption(
        year: event.year!,
        month: event.month,
        areaId: event.areaId,
      ),
      emit,
      (data) {
        // Save to cache
        saveConsumption(stats: data, year: event.year!, areaId: event.areaId);
        return ConsumptionLoaded(consumptionData: data);
      },
      'consumption',
    );
  }

  Future<void> _onLoadCachedConsumption(LoadCachedConsumption event, Emitter<StatisticsState> emit) async {
    await _handleRequest(
      () => loadCachedConsumption(year: event.year, areaId: event.areaId),
      emit,
      (data) => ConsumptionLoaded(consumptionData: data),
      'cached_consumption',
    );
  }

  Future<void> _onFetchRoomStatusStats(FetchRoomStatusStats event, Emitter<StatisticsState> emit) async {
    await _handleRequest(
      () => getRoomStatusStats(
        year: event.year,
        month: event.month,
        quarter: event.quarter,
        areaId: event.areaId,
        roomId: event.roomId,
      ),
      emit,
      (data) => RoomStatusLoaded(roomStatusData: data),
      'room_status',
    );
  }
  Future<void> _onFetchRoomStatusSummary(FetchRoomStatusSummary event, Emitter<StatisticsState> emit) async {
    await _handleRequest(
      () => getRoomStatusSummary(
        year: event.year,
        areaId: event.areaId,
      ),
      emit,
      (data) => RoomStatusSummaryLoaded(summaryData: data),
      'room_status_summary',
    );
  }

  Future<void> _onFetchUserSummary(FetchUserSummary event, Emitter<StatisticsState> emit) async {
    await _handleRequest(
      () => getUserSummary(
        year: event.year,
        areaId: event.areaId,
      ),
      emit,
      (data) => UserSummaryLoaded(summaryData: data),
      'user_summary',
    );
  }

  Future<void> _onTriggerManualSnapshot(TriggerManualSnapshot event, Emitter<StatisticsState> emit) async {
    await _handleRequest(
      () => triggerManualSnapshot.call(
        year: event.year,
        month: event.month,
      ),
      emit,
      (_) => ManualSnapshotTriggered(message: 'Snapshot triggered successfully'),
      'manual_snapshot',
    );
  }

  Future<void> _onFetchRoomCapacityStats(FetchRoomCapacityStats event, Emitter<StatisticsState> emit) async {
    await _handleRequest(
      () => getRoomCapacityStats(
        year: event.year,
        month: event.month,
        quarter: event.quarter,
        areaId: event.areaId,
      ),
      emit,
      (data) => RoomCapacityLoaded(roomCapacityData: data),
      'room_capacity',
    );
  }

  Future<void> _onFetchContractStats(FetchContractStats event, Emitter<StatisticsState> emit) async {
    await _handleRequest(
      () => getContractStats(
        year: event.year,
        month: event.month,
        quarter: event.quarter,
        areaId: event.areaId,
      ),
      emit,
      (data) => ContractStatsLoaded(contractStatsData: data),
      'contract_stats',
    );
  }

  Future<void> _onFetchUserStats(FetchUserStats event, Emitter<StatisticsState> emit) async {
    await _handleRequest(
      () => getUserStats(areaId: event.areaId),
      emit,
      (data) => UserStatsLoaded(userStatsData: data),
      'user_stats',
    );
  }

  Future<void> _onFetchUserMonthlyStats(FetchUserMonthlyStats event, Emitter<StatisticsState> emit) async {
    await _handleRequest(
      () => getUserMonthlyStats(
        year: event.year,
        month: event.month,
        quarter: event.quarter,
        areaId: event.areaId,
        roomId: event.roomId,
      ),
      emit,
      (data) => UserMonthlyStatsLoaded(userMonthlyStatsData: data),
      'user_monthly_stats',
    );
  }

  Future<void> _onFetchOccupancyRateStats(FetchOccupancyRateStats event, Emitter<StatisticsState> emit) async {
    await _handleRequest(
      () => getOccupancyRateStats(areaId: event.areaId),
      emit,
      (data) => OccupancyRateLoaded(occupancyRateData: data),
      'occupancy_rate',
    );
  }  Future<void> _onFetchReportStats(FetchReportStats event, Emitter<StatisticsState> emit) async {
    // Nếu không yêu cầu cập nhật mới và có dữ liệu cache, sử dụng cache
    if (!event.forceRefresh) {
      try {
        final cachedReports = await loadCachedReportStats();
        if (cachedReports.isRight()) {
          // Kiểm tra nếu có dữ liệu cache
          final reports = cachedReports.getOrElse(() => []);
          if (reports.isNotEmpty) {
            emit(ReportStatsLoaded(reportStatsData: reports, trends: []));
            return;
          }
        }
      } catch (_) {
        // Xử lý lỗi khi truy cập cache, tiếp tục lấy từ server
      }
    }

    // Lấy dữ liệu mới từ server
    await _handleRequest(
      () => getReportStats(
        year: event.year,
        month: event.month,
        areaId: event.areaId,
      ),
      emit,
      (data) => ReportStatsLoaded(reportStatsData: data.reportStats, trends: data.trends),
      'report_stats',
    );
  }

  Future<void> _onFetchRoomFillRateStats(FetchRoomFillRateStats event, Emitter<StatisticsState> emit) async {
    await _handleRequest(
      () => getRoomFillRateStats(
        areaId: event.areaId,
        roomId: event.roomId,
      ),
      emit,
      (data) {
        // Save to cache
        saveRoomFillRate(stats: data, areaId: event.areaId);
        return RoomFillRateLoaded(roomFillRateData: data);
      },
      'room_fill_rate',
    );
  }

  Future<void> _onLoadCachedRoomFillRateStats(LoadCachedRoomFillRateStats event, Emitter<StatisticsState> emit) async {
    await _handleRequest(
      () => loadCachedRoomFillRate(areaId: event.areaId),
      emit,
      (data) => RoomFillRateLoaded(roomFillRateData: data),
      'cached_room_fill_rate',
    );
  }

  Future<void> _onLoadCachedRoomStats(LoadCachedRoomStatsEvent event, Emitter<StatisticsState> emit) async {
    await _handleRequest(
      () => loadCachedRoomStats(),
      emit,
      (data) => RoomStatusLoaded(roomStatusData: data),
      'cached_room_status',
    );
  }

  Future<void> _onLoadCachedUserMonthlyStats(LoadCachedUserMonthlyStatsEvent event, Emitter<StatisticsState> emit) async {
    await _handleRequest(
      () => loadCachedUserMonthlyStats(),
      emit,
      (data) => UserMonthlyStatsLoaded(userMonthlyStatsData: data),
      'cached_user_monthly_stats',
    );
  }

  Future<void> _onLoadCachedReportStats(LoadCachedReportStatsEvent event, Emitter<StatisticsState> emit) async {
    await _handleRequest(
      () => loadCachedReportStats(),
      emit,
      (data) => ReportStatsLoaded(reportStatsData: data, trends: []),
      'cached_report_stats',
    );
  }

  Future<void> _onLoadCachedUserStats(LoadCachedUserStatsEvent event, Emitter<StatisticsState> emit) async {
    await _handleRequest(
      () => loadCachedUserStats(),
      emit,
      (data) => UserStatsLoaded(userStatsData: data),
      'cached_user_stats',
    );
  }
}
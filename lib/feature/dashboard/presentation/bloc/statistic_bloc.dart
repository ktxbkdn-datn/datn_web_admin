import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../domain/usecase/statistic_usecase.dart';
import 'statistic_event.dart';
import 'statistic_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetMonthlyConsumption getMonthlyConsumption;
  final GetRoomStatusStats getRoomStatusStats;
  final GetRoomCapacityStats getRoomCapacityStats;
  final GetContractStats getContractStats;
  final GetUserStats getUserStats;
  final GetUserMonthlyStats getUserMonthlyStats;
  final GetOccupancyRateStats getOccupancyRateStats;
  final GetReportStats getReportStats;
  final LoadCachedRoomStats loadCachedRoomStats;
  final LoadCachedUserMonthlyStats loadCachedUserMonthlyStats;
  final LoadCachedReportStats loadCachedReportStats;
  final LoadCachedUserStats loadCachedUserStats;

  StatisticsBloc({
    required this.getMonthlyConsumption,
    required this.getRoomStatusStats,
    required this.getRoomCapacityStats,
    required this.getContractStats,
    required this.getUserStats,
    required this.getUserMonthlyStats,
    required this.getOccupancyRateStats,
    required this.getReportStats,
    required this.loadCachedRoomStats,
    required this.loadCachedUserMonthlyStats,
    required this.loadCachedReportStats,
    required this.loadCachedUserStats,
  }) : super(StatisticsInitial()) {
    on<FetchMonthlyConsumption>(_onFetchMonthlyConsumption);
    on<FetchRoomStatusStats>(_onFetchRoomStatusStats);
    on<FetchRoomCapacityStats>(_onFetchRoomCapacityStats);
    on<FetchContractStats>(_onFetchContractStats);
    on<FetchUserStats>(_onFetchUserStats);
    on<FetchUserMonthlyStats>(_onFetchUserMonthlyStats);
    on<FetchOccupancyRateStats>(_onFetchOccupancyRateStats);
    on<FetchReportStats>(_onFetchReportStats);
    on<LoadCachedRoomStatsEvent>(_onLoadCachedRoomStats);
    on<LoadCachedUserMonthlyStatsEvent>(_onLoadCachedUserMonthlyStats);
    on<LoadCachedReportStatsEvent>(_onLoadCachedReportStats);
    on<LoadCachedUserStatsEvent>(_onLoadCachedUserStats);
  }

  Future<void> _onFetchMonthlyConsumption(FetchMonthlyConsumption event, Emitter<StatisticsState> emit) async {
    emit(StatisticsLoading());
    final result = await getMonthlyConsumption(
      year: event.year,
      month: event.month,
      areaId: event.areaId,
    );
    result.fold(
      (failure) => emit(StatisticsError(failure.message)),
      (consumptionData) => emit(ConsumptionLoaded(consumptionData: consumptionData)),
    );
  }

  Future<void> _onFetchRoomStatusStats(FetchRoomStatusStats event, Emitter<StatisticsState> emit) async {
    emit(StatisticsLoading());
    final result = await getRoomStatusStats(
      year: event.year,
      month: event.month,
      quarter: event.quarter,
      areaId: event.areaId,
    );
    result.fold(
      (failure) => emit(StatisticsError(failure.message)),
      (roomStatusData) => emit(RoomStatusLoaded(roomStatusData: roomStatusData)),
    );
  }

  Future<void> _onFetchRoomCapacityStats(FetchRoomCapacityStats event, Emitter<StatisticsState> emit) async {
    emit(StatisticsLoading());
    final result = await getRoomCapacityStats(
      year: event.year,
      month: event.month,
      quarter: event.quarter,
      areaId: event.areaId,
    );
    result.fold(
      (failure) => emit(StatisticsError(failure.message)),
      (roomCapacityData) => emit(RoomCapacityLoaded(roomCapacityData: roomCapacityData)),
    );
  }

  Future<void> _onFetchContractStats(FetchContractStats event, Emitter<StatisticsState> emit) async {
    emit(StatisticsLoading());
    final result = await getContractStats(
      year: event.year,
      month: event.month,
      quarter: event.quarter,
      areaId: event.areaId,
    );
    result.fold(
      (failure) => emit(StatisticsError(failure.message)),
      (contractStatsData) => emit(ContractStatsLoaded(contractStatsData: contractStatsData)),
    );
  }

  Future<void> _onFetchUserStats(FetchUserStats event, Emitter<StatisticsState> emit) async {
    emit(StatisticsLoading());
    final result = await getUserStats(areaId: event.areaId);
    result.fold(
      (failure) => emit(StatisticsError(failure.message)),
      (userStatsData) => emit(UserStatsLoaded(userStatsData: userStatsData)),
    );
  }

  Future<void> _onFetchUserMonthlyStats(FetchUserMonthlyStats event, Emitter<StatisticsState> emit) async {
    emit(StatisticsLoading());
    final result = await getUserMonthlyStats(
      year: event.year,
      month: event.month,
      quarter: event.quarter,
      areaId: event.areaId,
    );
    result.fold(
      (failure) => emit(StatisticsError(failure.message)),
      (userMonthlyStatsData) => emit(UserMonthlyStatsLoaded(userMonthlyStatsData: userMonthlyStatsData)),
    );
  }

  Future<void> _onFetchOccupancyRateStats(FetchOccupancyRateStats event, Emitter<StatisticsState> emit) async {
    emit(StatisticsLoading());
    final result = await getOccupancyRateStats(areaId: event.areaId);
    result.fold(
      (failure) => emit(StatisticsError(failure.message)),
      (occupancyRateData) => emit(OccupancyRateLoaded(occupancyRateData: occupancyRateData)),
    );
  }

  Future<void> _onFetchReportStats(FetchReportStats event, Emitter<StatisticsState> emit) async {
    emit(StatisticsLoading());
    final result = await getReportStats(
      year: event.year,
      month: event.month,
      areaId: event.areaId,
    );
    result.fold(
      (failure) => emit(StatisticsError(failure.message)),
      (response) => emit(ReportStatsLoaded(
        reportStatsData: response.reportStats,
        trends: response.trends,
      )),
    );
  }

  Future<void> _onLoadCachedRoomStats(LoadCachedRoomStatsEvent event, Emitter<StatisticsState> emit) async {
    emit(StatisticsLoading());
    final result = await loadCachedRoomStats();
    result.fold(
      (failure) => emit(StatisticsError(failure.message)),
      (roomStatusData) => emit(RoomStatusLoaded(roomStatusData: roomStatusData)),
    );
  }

  Future<void> _onLoadCachedUserMonthlyStats(LoadCachedUserMonthlyStatsEvent event, Emitter<StatisticsState> emit) async {
    emit(StatisticsLoading());
    final result = await loadCachedUserMonthlyStats();
    result.fold(
      (failure) => emit(StatisticsError(failure.message)),
      (userMonthlyStatsData) => emit(UserMonthlyStatsLoaded(userMonthlyStatsData: userMonthlyStatsData)),
    );
  }

  Future<void> _onLoadCachedReportStats(LoadCachedReportStatsEvent event, Emitter<StatisticsState> emit) async {
    emit(StatisticsLoading());
    final result = await loadCachedReportStats();
    result.fold(
      (failure) => emit(StatisticsError(failure.message)),
      (reportStatsData) => emit(ReportStatsLoaded(
        reportStatsData: reportStatsData,
        trends: [], // Trends not cached for simplicity
      )),
    );
  }

  Future<void> _onLoadCachedUserStats(LoadCachedUserStatsEvent event, Emitter<StatisticsState> emit) async {
    emit(StatisticsLoading());
    final result = await loadCachedUserStats();
    result.fold(
      (failure) => emit(StatisticsError(failure.message)),
      (userStatsData) => emit(UserStatsLoaded(userStatsData: userStatsData)),
    );
  }
}
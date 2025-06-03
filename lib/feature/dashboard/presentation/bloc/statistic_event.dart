import 'package:equatable/equatable.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

class FetchMonthlyConsumption extends StatisticsEvent {
  final int year;
  final int? month;
  final int? areaId;

  const FetchMonthlyConsumption({
    required this.year,
    this.month,
    this.areaId,
  });

  @override
  List<Object?> get props => [year, month, areaId];
}

class LoadCachedConsumption extends StatisticsEvent {
  final int year;
  final int? areaId;

  const LoadCachedConsumption({
    required this.year,
    this.areaId,
  });

  @override
  List<Object?> get props => [year, areaId];
}

class FetchRoomStatusStats extends StatisticsEvent {
  final int? year;
  final int? month;
  final int? quarter;
  final int? areaId;
  final int? roomId;

  const FetchRoomStatusStats({
    this.year,
    this.month,
    this.quarter,
    this.areaId,
    this.roomId,
  });

  @override
  List<Object?> get props => [year, month, quarter, areaId, roomId];
}

class FetchRoomStatusSummary extends StatisticsEvent {
  final int year;
  final int? areaId;

  const FetchRoomStatusSummary({
    required this.year,
    this.areaId,
  });

  @override
  List<Object?> get props => [year, areaId];
}

class FetchUserSummary extends StatisticsEvent {
  final int year;
  final int? areaId;

  const FetchUserSummary({
    required this.year,
    this.areaId,
  });

  @override
  List<Object?> get props => [year, areaId];
}

class TriggerManualSnapshot extends StatisticsEvent {
  final int year;
  final int? month;

  const TriggerManualSnapshot({
    required this.year,
    this.month,
  });

  @override
  List<Object?> get props => [year, month];
}

class FetchRoomCapacityStats extends StatisticsEvent {
  final int? year;
  final int? month;
  final int? quarter;
  final int? areaId;

  const FetchRoomCapacityStats({
    this.year,
    this.month,
    this.quarter,
    this.areaId,
  });

  @override
  List<Object?> get props => [year, month, quarter, areaId];
}

class FetchContractStats extends StatisticsEvent {
  final int? year;
  final int? month;
  final int? quarter;
  final int? areaId;

  const FetchContractStats({
    this.year,
    this.month,
    this.quarter,
    this.areaId,
  });

  @override
  List<Object?> get props => [year, month, quarter, areaId];
}

class FetchUserStats extends StatisticsEvent {
  final int? areaId;

  const FetchUserStats({
    this.areaId,
  });

  @override
  List<Object?> get props => [areaId];
}

class FetchUserMonthlyStats extends StatisticsEvent { // Renamed from FetchUserMonthStats
  final int? year;
  final int? month;
  final int? quarter;
  final int? areaId;
  final int? roomId;

  const FetchUserMonthlyStats({
    this.year,
    this.month,
    this.quarter,
    this.areaId,
    this.roomId,
  });

  @override
  List<Object?> get props => [year, month, quarter, areaId, roomId];
}

class FetchOccupancyRateStats extends StatisticsEvent {
  final int? areaId;

  const FetchOccupancyRateStats({
    this.areaId,
  });

  @override
  List<Object?> get props => [areaId];
}

class FetchReportStats extends StatisticsEvent {
  final int? year;
  final int? month;
  final int? areaId;

  const FetchReportStats({
    this.year,
    this.month,
    this.areaId,
  });

  @override
  List<Object?> get props => [year, month, areaId];
}

class LoadCachedRoomStatsEvent extends StatisticsEvent {
  const LoadCachedRoomStatsEvent();
  @override
  List<Object?> get props => [];
}

class LoadCachedUserMonthlyStatsEvent extends StatisticsEvent { // Renamed from LoadCachedUserMonthStatsEvent
  const LoadCachedUserMonthlyStatsEvent();
  @override
  List<Object?> get props => [];
}

class LoadCachedReportStatsEvent extends StatisticsEvent {
  const LoadCachedReportStatsEvent();
  @override
  List<Object?> get props => [];
}

class LoadCachedUserStatsEvent extends StatisticsEvent {
  const LoadCachedUserStatsEvent();
  @override
  List<Object?> get props => [];
}
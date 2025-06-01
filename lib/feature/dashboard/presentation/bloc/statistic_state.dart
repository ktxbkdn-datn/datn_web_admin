import 'package:equatable/equatable.dart';
import '../../domain/entities/consumption.dart';
import '../../domain/entities/room_status.dart';
import '../../domain/entities/room_capacity.dart';
import '../../domain/entities/contract_stats.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/entities/user_monthly_stats.dart';
import '../../domain/entities/occupancy_rate.dart';
import '../../domain/entities/report_stats.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ConsumptionLoaded extends StatisticsState {
  final List<Consumption> consumptionData;

  const ConsumptionLoaded({
    required this.consumptionData,
  });

  @override
  List<Object?> get props => [consumptionData];
}

class RoomStatusLoaded extends StatisticsState {
  final List<RoomStatus> roomStatusData;

  const RoomStatusLoaded({
    required this.roomStatusData,
  });

  @override
  List<Object?> get props => [roomStatusData];
}

class RoomCapacityLoaded extends StatisticsState {
  final List<RoomCapacity> roomCapacityData;

  const RoomCapacityLoaded({
    required this.roomCapacityData,
  });

  @override
  List<Object?> get props => [roomCapacityData];
}

class ContractStatsLoaded extends StatisticsState {
  final List<ContractStats> contractStatsData;

  const ContractStatsLoaded({
    required this.contractStatsData,
  });

  @override
  List<Object?> get props => [contractStatsData];
}

class UserStatsLoaded extends StatisticsState {
  final List<UserStats> userStatsData;

  const UserStatsLoaded({
    required this.userStatsData,
  });

  @override
  List<Object?> get props => [userStatsData];
}

class UserMonthlyStatsLoaded extends StatisticsState {
  final List<UserMonthlyStats> userMonthlyStatsData;

  const UserMonthlyStatsLoaded({
    required this.userMonthlyStatsData,
  });

  @override
  List<Object?> get props => [userMonthlyStatsData];
}

class OccupancyRateLoaded extends StatisticsState {
  final List<OccupancyRate> occupancyRateData;

  const OccupancyRateLoaded({
    required this.occupancyRateData,
  });

  @override
  List<Object?> get props => [occupancyRateData];
}

class ReportStatsLoaded extends StatisticsState {
  final List<ReportStats> reportStatsData;
  final List<ReportTrend> trends;

  const ReportStatsLoaded({
    required this.reportStatsData,
    required this.trends,
  });

  @override
  List<Object?> get props => [reportStatsData, trends];
}
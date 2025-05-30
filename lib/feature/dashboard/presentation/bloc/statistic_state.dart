// lib/src/features/statistics/presentation/bloc/statistic_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/consumption.dart';

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
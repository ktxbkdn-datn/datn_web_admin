// lib/src/features/statistics/presentation/bloc/statistic_event.dart
import 'package:equatable/equatable.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

class FetchMonthlyConsumption extends StatisticsEvent {
  final int? year;
  final int? month;
  final int? areaId; // Thêm areaId

  const FetchMonthlyConsumption({
    this.year,
    this.month,
    this.areaId,
  });

  @override
  List<Object?> get props => [year, month, areaId];
}
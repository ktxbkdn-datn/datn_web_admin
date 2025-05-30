// lib/src/features/statistics/presentation/bloc/statistic_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../domain/usecase/statistic_usecase.dart';
import 'statistic_event.dart';
import 'statistic_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetMonthlyConsumption getMonthlyConsumption;

  StatisticsBloc({
    required this.getMonthlyConsumption,
  }) : super(StatisticsInitial()) {
    on<FetchMonthlyConsumption>(_onFetchMonthlyConsumption);
  }

  Future<void> _onFetchMonthlyConsumption(FetchMonthlyConsumption event, Emitter<StatisticsState> emit) async {
    emit(StatisticsLoading());
    final result = await getMonthlyConsumption(
      year: event.year,
      month: event.month,
      areaId: event.areaId, // Truyền areaId
    );
    result.fold(
      (failure) => emit(StatisticsError(failure.message)),
      (consumptionData) => emit(ConsumptionLoaded(
        consumptionData: consumptionData,
      )),
    );
  }
}
// lib/src/features/report/presentations/bloc_rt/report_type_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/report_type_entity.dart';

abstract class ReportTypeState extends Equatable {
  const ReportTypeState();

  @override
  List<Object> get props => [];
}

class ReportTypeInitial extends ReportTypeState {}

class ReportTypeLoading extends ReportTypeState {}

class ReportTypesLoaded extends ReportTypeState {
  final List<ReportTypeEntity> reportTypes;

  const ReportTypesLoaded({required this.reportTypes});

  @override
  List<Object> get props => [reportTypes];
}

class ReportTypeError extends ReportTypeState {
  final String message;

  const ReportTypeError({required this.message});

  @override
  List<Object> get props => [message];
}

class ReportTypeCreated extends ReportTypeState {
  final List<ReportTypeEntity> reportTypes;

  const ReportTypeCreated({required this.reportTypes});

  @override
  List<Object> get props => [reportTypes];
}

class ReportTypeUpdated extends ReportTypeState {
  final List<ReportTypeEntity> reportTypes;

  const ReportTypeUpdated({required this.reportTypes});

  @override
  List<Object> get props => [reportTypes];
}

class ReportTypeDeleted extends ReportTypeState {
  final int reportTypeId;

  const ReportTypeDeleted({required this.reportTypeId});

  @override
  List<Object> get props => [reportTypeId];
}
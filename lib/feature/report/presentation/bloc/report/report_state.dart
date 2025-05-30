// lib/src/features/report/presentations/bloc_r/report_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/report_entity.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportsLoaded extends ReportState {
  final List<ReportEntity> reports;

  const ReportsLoaded({required this.reports});

  @override
  List<Object> get props => [reports];
}

class ReportLoaded extends ReportState {
  final ReportEntity report;

  const ReportLoaded({required this.report});

  @override
  List<Object> get props => [report];
}

class ReportUpdated extends ReportState {
  final ReportEntity report;

  const ReportUpdated({required this.report});

  @override
  List<Object> get props => [report];
}

class ReportStatusUpdated extends ReportState {
  final ReportEntity report;

  const ReportStatusUpdated({required this.report});

  @override
  List<Object> get props => [report];
}

class ReportError extends ReportState {
  final String message;

  const ReportError({required this.message});

  @override
  List<Object> get props => [message];
}

class ReportDeleted extends ReportState {
  final int reportId;

  const ReportDeleted({required this.reportId});

  @override
  List<Object> get props => [reportId];
}
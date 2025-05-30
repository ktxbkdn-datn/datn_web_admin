// lib/src/features/report/presentations/bloc_rt/report_type_event.dart
import 'package:equatable/equatable.dart';

abstract class ReportTypeEvent extends Equatable {
  const ReportTypeEvent();

  @override
  List<Object?> get props => [];
}

class GetAllReportTypesEvent extends ReportTypeEvent {
  final int page;
  final int limit;

  const GetAllReportTypesEvent({this.page = 1, this.limit = 10});

  @override
  List<Object?> get props => [page, limit];
}

class CreateReportTypeEvent extends ReportTypeEvent {
  final String name;

  const CreateReportTypeEvent({required this.name});

  @override
  List<Object?> get props => [name];
}

class UpdateReportTypeEvent extends ReportTypeEvent {
  final int reportTypeId;
  final String name;

  const UpdateReportTypeEvent({required this.reportTypeId, required this.name});

  @override
  List<Object?> get props => [reportTypeId, name];
}

class DeleteReportTypeEvent extends ReportTypeEvent {
  final int reportTypeId;

  const DeleteReportTypeEvent({required this.reportTypeId});

  @override
  List<Object?> get props => [reportTypeId];
}

class ResetReportTypeStateEvent extends ReportTypeEvent {
  const ResetReportTypeStateEvent();

  @override
  List<Object?> get props => [];
}
import 'package:equatable/equatable.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class GetAllReportsEvent extends ReportEvent {
  final int page;
  final int limit;
  final int? userId;
  final int? roomId;
  final String? status;
  final int? reportTypeId;
  final String? searchQuery;
  final bool forceRefresh;

  const GetAllReportsEvent({
    this.page = 1,
    this.limit = 10,
    this.userId,
    this.roomId,
    this.status,
    this.reportTypeId,
    this.searchQuery,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [page, limit, userId, roomId, status, reportTypeId, searchQuery, forceRefresh];
}

class GetReportByIdEvent extends ReportEvent {
  final int reportId;

  const GetReportByIdEvent(this.reportId);

  @override
  List<Object?> get props => [reportId];
}

class UpdateReportEvent extends ReportEvent {
  final int reportId;
  final int roomId;
  final int reportTypeId;
  final String description;
  final String status;

  const UpdateReportEvent({
    required this.reportId,
    required this.roomId,
    required this.reportTypeId,
    required this.description,
    required this.status,
  });

  @override
  List<Object?> get props => [reportId, roomId, reportTypeId, description, status];
}

class UpdateReportStatusEvent extends ReportEvent {
  final int reportId;
  final String status;

  const UpdateReportStatusEvent({
    required this.reportId,
    required this.status,
  });

  @override
  List<Object?> get props => [reportId, status];
}

class DeleteReportEvent extends ReportEvent {
  final int reportId;

  const DeleteReportEvent({required this.reportId});

  @override
  List<Object?> get props => [reportId];
}

class ResetReportStateEvent extends ReportEvent {
  const ResetReportStateEvent();

  @override
  List<Object?> get props => [];
}
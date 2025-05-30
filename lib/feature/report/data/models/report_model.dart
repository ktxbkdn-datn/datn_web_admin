// lib/src/features/report/data/models/report_model.dart
import '../../domain/entities/report_entity.dart';

class ReportModel extends ReportEntity {
  ReportModel({
    required int reportId,
    required int reportTypeId,
    required String title,
    required int roomId,
    required String status,
    String? description,
    required int userId,
    String? createdAt,
    String? updatedAt,
    String? resolvedAt,
    String? closedAt,
    String? reportTypeName,
    String? roomName,
    String? areaName,
    String? userEmail,
    String? userFullname,
    String? userPhone,
  }) : super(
    reportId: reportId,
    reportTypeId: reportTypeId,
    title: title,
    roomId: roomId,
    status: status,
    description: description,
    userId: userId,
    createdAt: createdAt,
    updatedAt: updatedAt,
    resolvedAt: resolvedAt,
    closedAt: closedAt,
    reportTypeName: reportTypeName,
    roomName: roomName,
    areaName: areaName,
    userEmail: userEmail,
    userFullname: userFullname,
    userPhone: userPhone,
  );

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      reportId: json['report_id'] as int,
      reportTypeId: json['report_type_id'] as int,
      title: json['title'] as String,
      roomId: json['room_id'] as int,
      status: json['status'] as String,
      description: json['description'] as String?,
      userId: json['user_id'] as int,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      resolvedAt: json['resolved_at'] as String?,
      closedAt: json['closed_at'] as String?,
      reportTypeName: json['report_type_details'] != null ? json['report_type_details']['name'] as String? : null,
      roomName: json['room_details'] != null ? json['room_details']['name'] as String? : null,
      areaName: json['room_details'] != null && json['room_details']['area_details'] != null
          ? json['room_details']['area_details']['name'] as String?
          : null,
      userEmail: json['user_details'] != null ? json['user_details']['email'] as String? : null,
      userFullname: json['user_details'] != null ? json['user_details']['fullname'] as String? : null,
      userPhone: json['user_details'] != null ? json['user_details']['phone'] as String? : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'report_id': reportId,
      'report_type_id': reportTypeId,
      'title': title,
      'room_id': roomId,
      'status': status,
      'description': description,
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'resolved_at': resolvedAt,
      'closed_at': closedAt,
      'report_type_name': reportTypeName,
      'room_name': roomName,
      'area_name': areaName,
      'user_email': userEmail,
      'user_fullname': userFullname,
      'user_phone': userPhone,
    };
  }
}
// lib/src/features/report/domain/entities/report_entity.dart
class ReportEntity {
  final int reportId;
  final int reportTypeId;
  final String title;
  final int roomId;
  final String status;
  final String? description;
  final int userId;
  final String? createdAt;
  final String? updatedAt;
  final String? resolvedAt;
  final String? closedAt;
  final String? reportTypeName; // Từ report_type_details.name
  final String? roomName; // Từ room_details.name
  final String? areaName; // Từ room_details.area_details.name
  final String? userEmail; // Từ user_details.email
  final String? userFullname; // Từ user_details.fullname
  final String? userPhone; // Từ user_details.phone

  const ReportEntity({
    required this.reportId,
    required this.reportTypeId,
    required this.title,
    required this.roomId,
    required this.status,
    this.description,
    required this.userId,
    this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.closedAt,
    this.reportTypeName,
    this.roomName,
    this.areaName,
    this.userEmail,
    this.userFullname,
    this.userPhone,
  });

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

  factory ReportEntity.fromJson(Map<String, dynamic> json) {
    return ReportEntity(
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
}
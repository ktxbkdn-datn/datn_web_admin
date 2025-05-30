import 'package:datn_web_admin/feature/room/domain/entities/room_entity.dart';

class Registration {
  final int? registrationId;
  final String nameStudent;
  final String email;
  final String phoneNumber;
  final String information;
  final String meetingLocation;
  final DateTime? meetingDatetime;
  final DateTime createdAt;
  final int? numberOfPeople;
  final String status;
  final String? roomName;  // Chỉ lưu tên của room
  final String? areaName;  // Chỉ lưu tên của area

  Registration({
    required this.registrationId,
    required this.nameStudent,
    required this.email,
    required this.phoneNumber,
    required this.information,
    required this.meetingLocation,
    this.meetingDatetime,
    required this.createdAt,
    required this.numberOfPeople,
    required this.status,
    this.roomName,
    this.areaName,
  });

  factory Registration.fromJson(Map<String, dynamic> json) {
    return Registration(
      registrationId: json['registration_id'] as int?,
      nameStudent: json['name_student'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      information: json['information'] as String? ?? '',
      meetingLocation: json['meeting_location'] as String? ?? '',
      meetingDatetime: json['meeting_datetime'] != null
          ? DateTime.parse(json['meeting_datetime'])
          : null,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      numberOfPeople: json['number_of_people'] as int?,
      status: json['status'] as String? ?? 'PENDING',
      roomName: json['room_name'] as String?,
      areaName: json['area_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'registration_id': registrationId,
      'name_student': nameStudent,
      'email': email,
      'phone_number': phoneNumber,
      'information': information,
      'meeting_location': meetingLocation,
      'meeting_datetime': meetingDatetime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'number_of_people': numberOfPeople,
      'status': status,
      'room_name': roomName,
      'area_name': areaName,
    };
  }
}
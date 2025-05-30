import 'package:equatable/equatable.dart';
import '../../domain/entity/register_entity.dart';

class RegistrationModel extends Equatable {
  final int? registrationId;
  final String nameStudent;
  final String email;
  final String phoneNumber;
  final String status;
  final String? information;
  final String createdAt;
  final int? numberOfPeople;
  final String? meetingDatetime;
  final String? meetingLocation;
  final String? roomName;  // Chỉ lưu tên của room
  final String? areaName;  // Chỉ lưu tên của area

  const RegistrationModel({
    required this.registrationId,
    required this.nameStudent,
    required this.email,
    required this.phoneNumber,
    required this.status,
    this.information,
    required this.createdAt,
    required this.numberOfPeople,
    this.meetingDatetime,
    this.meetingLocation,
    this.roomName,
    this.areaName,
  });

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    print('Parsing RegistrationModel: $json'); // Log dữ liệu JSON
    try {
      print('Parsing registrationId: ${json['registration_id']}');
      final registrationId = json['registration_id'] as int?;
      print('Parsing nameStudent: ${json['name_student']}');
      final nameStudent = json['name_student'] as String? ?? '';
      print('Parsing email: ${json['email']}');
      final email = json['email'] as String? ?? '';
      print('Parsing phoneNumber: ${json['phone_number']}');
      final phoneNumber = json['phone_number'] as String? ?? '';
      print('Parsing status: ${json['status']}');
      final status = json['status'] as String? ?? 'PENDING';
      print('Parsing information: ${json['information']}');
      final information = json['information'] as String?;
      print('Parsing createdAt: ${json['created_at']}');
      final createdAt = json['created_at'] as String? ?? DateTime.now().toIso8601String();
      print('Parsing numberOfPeople: ${json['number_of_people']}');
      final numberOfPeople = json['number_of_people'] as int?;
      print('Parsing meetingDatetime: ${json['meeting_datetime']}');
      final meetingDatetime = json['meeting_datetime'] as String?;
      print('Parsing meetingLocation: ${json['meeting_location']}');
      final meetingLocation = json['meeting_location'] as String?;

      // Lấy name của room và area từ room_details
      print('Parsing roomDetails: ${json['room_details']}');
      final roomName = json['room_details'] != null ? json['room_details']['name'] as String? : null;
      print('Parsing roomName: $roomName');
      final areaName = json['room_details'] != null && json['room_details']['area_details'] != null
          ? json['room_details']['area_details']['name'] as String?
          : null;
      print('Parsing areaName: $areaName');

      return RegistrationModel(
        registrationId: registrationId,
        nameStudent: nameStudent,
        email: email,
        phoneNumber: phoneNumber,
        status: status,
        information: information,
        createdAt: createdAt,
        numberOfPeople: numberOfPeople,
        meetingDatetime: meetingDatetime,
        meetingLocation: meetingLocation,
        roomName: roomName,
        areaName: areaName,
      );
    } catch (e) {
      print('Error parsing RegistrationModel: $e'); // Log lỗi parse
      rethrow; // Ném lại lỗi để log ở tầng trên có thể bắt được
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'registration_id': registrationId,
      'name_student': nameStudent,
      'email': email,
      'phone_number': phoneNumber,
      'status': status,
      'information': information,
      'created_at': createdAt,
      'number_of_people': numberOfPeople,
      'meeting_datetime': meetingDatetime,
      'meeting_location': meetingLocation,
      'room_name': roomName,
      'area_name': areaName,
    };
  }

  Registration toEntity() {
    return Registration(
      registrationId: registrationId,
      nameStudent: nameStudent,
      email: email,
      phoneNumber: phoneNumber,
      status: status,
      information: information ?? '',
      createdAt: DateTime.parse(createdAt),
      numberOfPeople: numberOfPeople ?? 0,
      meetingDatetime: meetingDatetime != null ? DateTime.parse(meetingDatetime!) : null,
      meetingLocation: meetingLocation ?? '',
      roomName: roomName,
      areaName: areaName,
    );
  }

  @override
  List<Object?> get props => [
    registrationId,
    nameStudent,
    email,
    phoneNumber,
    status,
    information,
    createdAt,
    numberOfPeople,
    meetingDatetime,
    meetingLocation,
    roomName,
    areaName,
  ];
}
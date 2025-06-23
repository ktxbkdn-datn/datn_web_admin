import 'package:equatable/equatable.dart';

import '../../domain/entities/contract_entity.dart';

class ContractModel extends Equatable {
  final int contractId;
  final int roomId;
  final int userId;
  final String status;
  final String createdAt;
  final String contractType;
  final String startDate;
  final String endDate;
  final String roomName;
  final String studentCode;
  final String? cccd;
  final String? className;
  final String? dateOfBirth;
  final String? fullname;
  final String? phone;
  final String? areaName;

  ContractModel({
    required this.contractId,
    required this.roomId,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.contractType,
    required this.startDate,
    required this.endDate,
    required this.roomName,
    required this.studentCode,
    this.cccd,
    this.className,
    this.dateOfBirth,
    this.fullname,
    this.phone,
    this.areaName,
  });

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      contractId: json['contract_id'] as int,
      roomId: json['room_id'] as int,
      userId: json['user_id'] as int,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      contractType: json['contract_type'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      roomName: json['room_details']['name'] as String? ?? '',
      studentCode: json['user_details']['student_code'] as String? ?? '',
      cccd: json['user_details']['CCCD'] as String?,
      className: json['user_details']['class_name'] as String?,
      dateOfBirth: json['user_details']['date_of_birth'] as String?,
      fullname: json['user_details']['fullname'] as String?,
      phone: json['user_details']['phone'] as String?,
      areaName: json['room_details']['area_details']['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_code': studentCode,
      'room_name': roomName,
      'contract_type': contractType,
      'start_date': startDate,
      'end_date': endDate,
    };
  }

  Contract toEntity() {
    return Contract(
      contractId: contractId,
      roomId: roomId,
      userId: userId,
      status: status,
      createdAt: createdAt,
      contractType: contractType,
      startDate: startDate,
      endDate: endDate,
      roomName: roomName,
      studentCode: studentCode,
      cccd: cccd,
      className: className,
      dateOfBirth: dateOfBirth,
      fullname: fullname,
      phone: phone,
      areaName: areaName,
    );
  }

  @override
  List<Object?> get props => [
    contractId,
    roomId,
    userId,
    status,
    createdAt,
    contractType,
    startDate,
    endDate,
    roomName,
    studentCode,
    cccd,
    className,
    dateOfBirth,
    fullname,
    phone,
    areaName,
  ];
}
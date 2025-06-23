import 'package:equatable/equatable.dart';

class Contract extends Equatable {
  final int contractId;
  final int roomId;
  final int userId;
  final String status;
  final String createdAt;
  final String contractType;
  final String startDate;
  final String endDate;
  final String roomName;
  final String studentCode; // Bắt buộc
  final String? userEmail; // Có thể bỏ nếu không dùng nữa
  final String? cccd;
  final String? className;
  final String? dateOfBirth;
  final String? fullname;
  final String? phone;
  final String? areaName;

  Contract({
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
    this.userEmail,
    this.cccd,
    this.className,
    this.dateOfBirth,
    this.fullname,
    this.phone,
    this.areaName,
  });

  Contract copyWith({
    int? contractId,
    int? roomId,
    int? userId,
    String? status,
    String? createdAt,
    String? contractType,
    String? startDate,
    String? endDate,
    String? roomName,
    String? studentCode, // Bắt buộc
    String? userEmail, // Có thể bỏ nếu không dùng nữa
    String? cccd,
    String? className,
    String? dateOfBirth,
    String? fullname,
    String? phone,
    String? areaName,
  }) {
    return Contract(
      contractId: contractId ?? this.contractId,
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      contractType: contractType ?? this.contractType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      roomName: roomName ?? this.roomName,
      studentCode: studentCode ?? this.studentCode, // Bắt buộc
      userEmail: userEmail ?? this.userEmail, // Có thể bỏ nếu không dùng nữa
      cccd: cccd ?? this.cccd,
      className: className ?? this.className,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      fullname: fullname ?? this.fullname,
      phone: phone ?? this.phone,
      areaName: areaName ?? this.areaName,
    );
  }

  // Chuyển Contract thành JSON
  Map<String, dynamic> toJson() {
    return {
      'contractId': contractId,
      'roomId': roomId,
      'userId': userId,
      'status': status,
      'createdAt': createdAt,
      'contractType': contractType,
      'startDate': startDate,
      'endDate': endDate,
      'roomName': roomName,
      'studentCode': studentCode, // Bắt buộc
      'userEmail': userEmail, // Có thể bỏ nếu không dùng nữa
      'cccd': cccd,
      'className': className,
      'dateOfBirth': dateOfBirth,
      'fullname': fullname,
      'phone': phone,
      'areaName': areaName,
    };
  }

  // Tạo Contract từ JSON
  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      contractId: json['contractId'] as int,
      roomId: json['roomId'] as int,
      userId: json['userId'] as int,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      contractType: json['contractType'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      roomName: json['roomName'] as String,
      studentCode: json['studentCode'] as String, // Bắt buộc
      userEmail: json['userEmail'] as String?,
      cccd: json['cccd'] as String?,
      className: json['className'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      fullname: json['fullname'] as String?,
      phone: json['phone'] as String?,
      areaName: json['areaName'] as String?,
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
    studentCode, // Bắt buộc
    userEmail, // Có thể bỏ nếu không dùng nữa
    cccd,
    className,
    dateOfBirth,
    fullname,
    phone,
    areaName,
  ];
}
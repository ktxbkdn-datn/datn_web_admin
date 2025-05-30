import 'package:equatable/equatable.dart';
import '../../domain/entities/monthly_bill_entity.dart';

class MonthlyBillModel extends Equatable {
  final int billId;
  final int userId;
  final int detailId;
  final int roomId;
  final DateTime billMonth;
  final double totalAmount;
  final String paymentStatus;
  final DateTime createdAt;
  final String? paymentMethodAllowed;
  final DateTime? paidAt;
  final String? transactionReference;
  final UserDetailsModel? userDetails;
  final RoomDetailsModel? roomDetails;
  final int? billDetailId;

  const MonthlyBillModel({
    required this.billId,
    required this.userId,
    required this.detailId,
    required this.roomId,
    required this.billMonth,
    required this.totalAmount,
    required this.paymentStatus,
    required this.createdAt,
    this.paymentMethodAllowed,
    this.paidAt,
    this.transactionReference,
    this.userDetails,
    this.roomDetails,
    this.billDetailId,
  });

  factory MonthlyBillModel.fromJson(Map<String, dynamic> json) {
    print('Parsing MonthlyBillModel: $json');
    try {
      final billId = json['bill_id'] as int;
      final userId = json['user_id'] as int;
      final detailId = json['detail_id'] as int;
      final roomId = json['room_id'] as int;
      final billMonth = DateTime.parse(json['bill_month'] as String);
      final totalAmount = double.parse(json['total_amount'] as String? ?? '0.00');
      final paymentStatus = json['payment_status'] as String;
      final createdAt = DateTime.parse(json['created_at'] as String);
      final paymentMethodAllowed = json['payment_method_allowed'] as String?;
      final paidAt = json['paid_at'] != null ? DateTime.parse(json['paid_at'] as String) : null;
      final transactionReference = json['transaction_reference'] as String?;
      final userDetails = json['user_details'] != null
          ? UserDetailsModel.fromJson(json['user_details'] as Map<String, dynamic>)
          : null;
      final roomDetails = json['room_details'] != null
          ? RoomDetailsModel.fromJson(json['room_details'] as Map<String, dynamic>)
          : null;
      final billDetailId = json['bill_detail_id'] as int?;

      return MonthlyBillModel(
        billId: billId,
        userId: userId,
        detailId: detailId,
        roomId: roomId,
        billMonth: billMonth,
        totalAmount: totalAmount,
        paymentStatus: paymentStatus,
        createdAt: createdAt,
        paymentMethodAllowed: paymentMethodAllowed,
        paidAt: paidAt,
        transactionReference: transactionReference,
        userDetails: userDetails,
        roomDetails: roomDetails,
        billDetailId: billDetailId,
      );
    } catch (e) {
      print('Error parsing MonthlyBillModel: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'bill_id': billId,
      'user_id': userId,
      'detail_id': detailId,
      'room_id': roomId,
      'bill_month': billMonth.toIso8601String(),
      'total_amount': totalAmount.toString(),
      'payment_status': paymentStatus,
      'created_at': createdAt.toIso8601String(),
      'payment_method_allowed': paymentMethodAllowed,
      'paid_at': paidAt?.toIso8601String(),
      'transaction_reference': transactionReference,
      'user_details': userDetails?.toJson(),
      'room_details': roomDetails?.toJson(),
      'bill_detail_id': billDetailId,
    };
  }

  MonthlyBill toEntity() {
    return MonthlyBill(
      billId: billId,
      userId: userId,
      detailId: detailId,
      roomId: roomId,
      billMonth: billMonth,
      totalAmount: totalAmount,
      paymentStatus: paymentStatus,
      createdAt: createdAt,
      paymentMethodAllowed: paymentMethodAllowed,
      paidAt: paidAt,
      transactionReference: transactionReference,
      userDetails: userDetails?.toEntity(),
      roomDetails: roomDetails?.toEntity(),
      billDetailId: billDetailId,
    );
  }

  @override
  List<Object?> get props => [
    billId,
    userId,
    detailId,
    roomId,
    billMonth,
    totalAmount,
    paymentStatus,
    createdAt,
    paymentMethodAllowed,
    paidAt,
    transactionReference,
    userDetails,
    roomDetails,
    billDetailId,
  ];
}

class UserDetailsModel extends Equatable {
  final int userId;
  final String fullname;
  final String email;

  const UserDetailsModel({
    required this.userId,
    required this.fullname,
    required this.email,
  });

  factory UserDetailsModel.fromJson(Map<String, dynamic> json) {
    print('Parsing UserDetailsModel: $json');
    try {
      final userId = json['user_id'] as int;
      final fullname = json['fullname'] as String? ?? '';
      final email = json['email'] as String? ?? '';

      return UserDetailsModel(
        userId: userId,
        fullname: fullname,
        email: email,
      );
    } catch (e) {
      print('Error parsing UserDetailsModel: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'fullname': fullname,
      'email': email,
    };
  }

  UserDetails toEntity() {
    return UserDetails(
      userId: userId,
      fullname: fullname,
      email: email,
    );
  }

  @override
  List<Object?> get props => [userId, fullname, email];
}

class RoomDetailsModel extends Equatable {
  final int roomId;
  final String name;

  const RoomDetailsModel({
    required this.roomId,
    required this.name,
  });

  factory RoomDetailsModel.fromJson(Map<String, dynamic> json) {
    print('Parsing RoomDetailsModel: $json');
    try {
      final roomId = json['room_id'] as int;
      final name = json['name'] as String? ?? '';

      return RoomDetailsModel(
        roomId: roomId,
        name: name,
      );
    } catch (e) {
      print('Error parsing RoomDetailsModel: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'name': name,
    };
  }

  RoomDetails toEntity() {
    return RoomDetails(
      roomId: roomId,
      name: name,
    );
  }

  @override
  List<Object?> get props => [roomId, name];
}
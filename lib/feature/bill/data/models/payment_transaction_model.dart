// lib/src/features/bill/data/models/payment_transaction_model.dart
class PaymentTransactionModel {
  final int transactionId;
  final int billId;
  final int userId;
  final double amount;
  final String transactionDate;
  final String paymentMethod;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final Map<String, dynamic>? billDetails;
  final Map<String, dynamic>? userDetails;

  PaymentTransactionModel({
    required this.transactionId,
    required this.billId,
    required this.userId,
    required this.amount,
    required this.transactionDate,
    required this.paymentMethod,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.billDetails,
    this.userDetails,
  });

  factory PaymentTransactionModel.fromJson(Map<String, dynamic> json) {
    return PaymentTransactionModel(
      transactionId: json['transaction_id'] as int,
      billId: json['bill_id'] as int,
      userId: json['user_id'] as int,
      amount: double.parse(json['amount'].toString()),
      transactionDate: json['transaction_date'] as String,
      paymentMethod: json['payment_method'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      billDetails: json['bill_details'] as Map<String, dynamic>?,
      userDetails: json['user_details'] as Map<String, dynamic>?,
    );
  }
}


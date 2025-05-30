class PaymentTransactionEntity {
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

  const PaymentTransactionEntity({
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
}
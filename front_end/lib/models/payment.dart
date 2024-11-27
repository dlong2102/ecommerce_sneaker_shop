class Payment {
  final String orderId;
  final String? paypalOrderId;
  final String status;
  final double amount;
  final String? paypalStatus;
  final String paymentMethod;
  final DateTime createdAt;

  Payment({
    required this.orderId,
    this.paypalOrderId,
    required this.status,
    required this.amount,
    required this.paymentMethod,
    this.paypalStatus,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      orderId: json['orderId'] ?? '',
      paypalOrderId: json['paypalOrderId'],
      status: json['status'] ?? '',
      amount: double.parse(json['amount'].toString()),
      paypalStatus: json['paypalStatus'],
      paymentMethod: json['paymentMethod'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

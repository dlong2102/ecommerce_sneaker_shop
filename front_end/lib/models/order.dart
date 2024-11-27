import '../models/payment.dart';
import '../models/user.dart';
import '../models/product.dart';

class Order {
  final String? id;
  final User user;
  final Payment payment;
  final Product product;
  final Payment status;
  final String paymentMethod;
  final DateTime createdAt;
  Order({
    this.id,
    required this.user,
    required this.payment,
    required this.product,
    required this.status,
    required this.paymentMethod,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] as String?,
      user: User.fromJson(json['user']),
      payment: Payment.fromJson(json['payment']),
      product: Product.fromJson(json['product']),
      status: Payment.fromJson(json['status']),
      paymentMethod: json['paymentMethod'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user.toJson(),
      'payment': payment,
      'product': product.toJson(),
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

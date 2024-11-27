import 'dart:async';
import 'dart:convert';
import 'package:ecommerce_sneaker_app/screens/payment/payment_status.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';
import '../main_screen.dart';
import '../models/payment.dart';

class PaymentService {
  static const String baseUrl = 'http://10.0.2.2:5000';
  Timer? _pollTimer;

  Future<List<Payment>?> getPaymentHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payment/history'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['payment'] != null) {
          return (data['payment'] as List)
              .map((payment) {
                try {
                  return Payment.fromJson(payment);
                } catch (e) {
                  debugPrint('Error parsing payment: $e');
                  return null;
                }
              })
              .where((payment) => payment != null)
              .cast<Payment>()
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getting payment history: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createCODOrder(double amount) async {
    if (amount <= 0) {
      return {
        'success': false,
        'message': 'Số tiền không hợp lệ',
      };
    }

    final String orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final Map<String, dynamic> requestBody = {
      'amount': amount,
      'orderId': orderId,
      'paymentMethod': 'COD',
    };

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/payment/create-cod-order'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'amount': data['amount'],
          'orderId': data['orderId'],
          'status': 'created',
          'paymentMethod': 'COD',
        };
      } else {
        throw Exception('Create COD order failed: ${response.body}');
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timeout',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> createPayment(double amount) async {
    if (amount <= 0) {
      return {
        'success': false,
        'message': 'Số tiền không hợp lệ',
      };
    }

    final String orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final Map<String, dynamic> requestBody = {
      'amount': amount,
      'orderId': orderId,
    };

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/payment/create-order'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'amount': data['amount'],
          'orderId': data['orderId'],
          'paypalOrderId': data['paypalOrderId'],
          'approveUrl': data['approveUrl'],
        };
      } else {
        throw Exception('Create order failed: ${response.body}');
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timeout',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Xử lý PayPal callback
  Future<void> handlePayPalCallback(Uri uri, BuildContext context) async {
    final String status = uri.queryParameters['status'] ?? '';
    final String paypalOrderId = uri.queryParameters['token'] ?? '';

    if (status == 'success') {
      // Kiểm tra trạng thái thanh toán
      await _checkPaymentCompletion(paypalOrderId, context);
      Navigator.pop(context);
    } else if (status == 'cancel') {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanh toán đã bị hủy')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> handlePayPalUrl(
      String url, String orderId, BuildContext context) async {
    try {
      if (await canLaunchUrlString(url)) {
        final result = await launchUrlString(
          url,
          mode: LaunchMode.externalApplication,
        );

        if (result) {
          Navigator.pop(context);
          // Bắt đầu kiểm tra trạng thái
          _startPollingOrderStatus(orderId, context);
        }
      } else {
        throw 'Could not launch PayPal URL';
      }
    } catch (e) {
      debugPrint('Error launching PayPal URL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _startPollingOrderStatus(String orderId, BuildContext context) {
    _pollTimer?.cancel(); // Cancel existing timer if any
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final orderStatus = await getOrderStatus(orderId);
      if (orderStatus != null) {
        if (orderStatus.status == 'COMPLETED') {
          timer.cancel();
          if (context.mounted) {
            // Hiển thị thông báo thanh toán thành công và chuyển hướng về trang PaymnetStatusScreen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thanh toán thành công')),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentStatusScreen(
                  status: 'success',
                  amount: orderStatus.amount,
                  orderId: orderStatus.orderId,
                ),
              ),
            );
          }
        } else if (orderStatus.status == 'CANCELLED') {
          timer.cancel();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thanh toán đã bị hủy')),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          }
        }
      }
    });
  }

  Future<Payment?> _checkPaymentCompletion(
      String paypalOrderId, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payment/capture-order'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'orderId': paypalOrderId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          if (context.mounted) {
            return Payment.fromJson(data['payment']);
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking payment completion: $e');
    }
    return null;
  }

  Future<Payment?> getOrderStatus(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payment/orders-status/$orderId'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['payment'] != null) {
          return Payment.fromJson(data['payment']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting order status: $e');
      return null;
    }
  }

  // Đảm bảo hủy timer khi không cần thiết
  void dispose() {
    _pollTimer?.cancel();
  }
}

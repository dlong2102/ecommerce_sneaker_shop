import 'package:flutter/material.dart';
import '../../models/payment.dart';
import '../../services/payment_service.dart';

class PaymentListTab extends StatefulWidget {
  const PaymentListTab({super.key});

  @override
  State<PaymentListTab> createState() => _PaymentListTabState();
}

class _PaymentListTabState extends State<PaymentListTab> {
  final PaymentService _paymentService = PaymentService();
  List<Payment>? _payments;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    try {
      // Giả sử bạn thêm method getPaymentHistory vào PaymentService
      final response = await _paymentService.getPaymentHistory();
      if (response != null) {
        setState(() {
          _payments = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi khi tải lịch sử thanh toán: ${e.toString()}')),
        );
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'CREATED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return 'Hoàn thành';
      case 'CANCELLED':
        return 'Đã hủy';
      case 'CREATED':
        return 'Đã tạo';
      default:
        return status;
    }
  }

  String _getPaymentMethod(String method) {
    switch (method.toUpperCase()) {
      case 'PAYPAL':
        return 'PayPal';
      case 'COD':
        return 'Thanh toán khi nhận hàng';
      default:
        return method;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chưa có đơn hàng nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_payments == null || _payments!.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadPayments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _payments!.length,
        itemBuilder: (context, index) {
          final payment = _payments![index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              childrenPadding: const EdgeInsets.all(16),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      payment.paymentMethod.toUpperCase() == 'COD'
                          ? Icons.local_shipping
                          : Icons.payment,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đơn hàng #${payment.orderId}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDateTime(payment.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(payment.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(payment.status),
                      style: TextStyle(
                        color: _getStatusColor(payment.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    _buildDetailRow('Tổng tiền',
                        '${payment.amount.toStringAsFixed(2)} VNĐ'),
                    const SizedBox(height: 8),
                    _buildDetailRow('Phương thức',
                        _getPaymentMethod(payment.paymentMethod)),
                    const SizedBox(height: 8),
                    _buildDetailRow('Mã giao dịch',
                        payment.paypalOrderId ?? payment.orderId),
                    const SizedBox(height: 8),
                    if (payment.status.toUpperCase() == 'COMPLETED') ...[
                      _buildDetailRow('Thông báo',
                          'Cám ơn đã thanh toán, shop sẽ giao hàng sớm cho bạn, thanks'),
                    ],
                    if (payment.status.toUpperCase() == 'CREATED') ...[
                      _buildDetailRow('Thông báo',
                          'Shop sẽ gọi và xác nhận đơn hàng cho bạn sớm, thanks'),
                    ],
                    if (payment.status.toUpperCase() == 'CANCELLED') ...[
                      const SizedBox(height: 8),
                      _buildDetailRow(
                          'Lý do', 'Đơn hàng đã bị hủy bởi người dùng'),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }
}

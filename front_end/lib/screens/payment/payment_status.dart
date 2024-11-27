import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../main_screen.dart';
import '../../providers/cart_provider.dart';

class PaymentStatusScreen extends StatelessWidget {
  final String status;
  final double amount;
  final String? orderId;

  const PaymentStatusScreen({
    super.key,
    required this.status,
    required this.amount,
    this.orderId,
  });

  String formatCurrency(double amount) {
    final formatCurrency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'VNĐ',
      decimalDigits: 0,
    );
    return formatCurrency.format(amount);
  }

  void _clearCartAndNavigateToMain(BuildContext context) {
    // Xóa giỏ hàng
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.clear(); // Phương thức để xóa toàn bộ giỏ hàng

    // Chuyển về trang chính
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (Route<dynamic> route) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title:
              const Text('Kết quả thanh toán', style: TextStyle(fontSize: 24)),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatusIcon(),
                const SizedBox(height: 24),
                _buildStatusMessage(),
                const SizedBox(height: 16),
                if (status == 'success') ...[
                  Text(
                    'Mã đơn hàng: $orderId',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  const Text(
                    'Shop sẽ liên hệ với bạn để xác nhận đơn hàng',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Số tiền: ${formatCurrency(amount)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (status) {
      case 'success':
        return const Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: 100,
        );
      case 'cancelled':
        return const Icon(
          Icons.cancel_outlined,
          color: Colors.orange,
          size: 100,
        );
      case 'created':
        return const Icon(
          Icons.pending_actions_outlined,
          color: Colors.blue,
          size: 100,
        );
      case 'error':
        return const Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 100,
        );
      default:
        return const Icon(
          Icons.help_outline,
          color: Colors.grey,
          size: 100,
        );
    }
  }

  Widget _buildStatusMessage() {
    String message;
    TextStyle style = const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
    );

    switch (status) {
      case 'success':
        message = 'Thanh toán thành công!';
        style = style.copyWith(color: Colors.green);
        break;
      case 'created':
        message = 'Đã tạo đơn hàng';
        style = style.copyWith(color: Colors.blue);
        break;
      case 'cancelled':
        message = 'Thanh toán đã bị hủy';
        style = style.copyWith(color: Colors.orange);
        break;
      case 'error':
        message = 'Thanh toán thất bại';
        style = style.copyWith(color: Colors.red);
        break;
      default:
        message = 'Trạng thái không xác định';
        style = style.copyWith(color: Colors.grey);
    }

    return Text(message, style: style, textAlign: TextAlign.center);
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        if (status == 'success') ...[
          ElevatedButton(
            onPressed: () => _clearCartAndNavigateToMain(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(200, 45),
            ),
            child: const Text('Về trang chính',
                style: TextStyle(color: Colors.white)),
          ),
        ] else if (status == 'created') ...[
          ElevatedButton(
            onPressed: () => _clearCartAndNavigateToMain(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(200, 45),
            ),
            child: const Text('Về trang chính',
                style: TextStyle(color: Colors.white)),
          ),
        ] else ...[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainScreen()),
                (Route<dynamic> route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 45),
            ),
            child: const Text('Thử lại'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainScreen()),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text('Về trang chính'),
          ),
        ],
      ],
    );
  }
}

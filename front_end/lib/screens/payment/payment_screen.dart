import 'dart:async';
import 'package:ecommerce_sneaker_app/models/cart.dart';
import 'package:ecommerce_sneaker_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import '../../models/payment.dart';
import '../../services/payment_service.dart';
import 'payment_status.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final List<CartItem> cartItems;

  const PaymentScreen(
      {super.key, required this.amount, required this.cartItems});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();

  // State variables
  bool _isLoading = false;
  bool _isProcessing = false;
  bool _hasStartedPayment = false;
  String? _orderId;
  String? _paypalUrl;
  String? _errorMessage;
  Payment? _order;
  Timer? _pollingTimer;
  String _selectedPaymentMethod = 'cod';

  static const _pollingDuration = Duration(seconds: 20);
  static const _maxPollingAttempts = 5;

  // Currency formatter
  final _currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'VNĐ',
    decimalDigits: 0,
  );

  String get _formattedAmount => _currencyFormatter.format(widget.amount);

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  // Payment Processing Methods
  Future<void> _processPayment() async {
    if (_isProcessing || widget.amount <= 0) {
      if (widget.amount <= 0) {
        _handleError(
            'Invalid payment amount. Amount must be greater than zero.');
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _isProcessing = true;
      _errorMessage = null;
      _hasStartedPayment = true;
    });

    try {
      if (_selectedPaymentMethod == 'cod') {
        // Xử lý thanh toán khi nhận hàng
        final result = await _paymentService.createCODOrder(widget.amount);
        if (!mounted) return;

        if (result['success']) {
          _orderId = result['orderId'];
          _handleOrderStatus('created');
        } else {
          _handleError(result['message'] ?? 'Error creating COD order');
        }
      } else {
        // Xử lý thanh toán PayPal
        final result = await _paymentService.createPayment(widget.amount);
        if (!mounted) return;

        if (result['success']) {
          _orderId = result['paypalOrderId'];
          if (_orderId?.isEmpty ?? true) {
            _handleError('Order ID is missing');
            return;
          }

          setState(() => _paypalUrl = result['approveUrl']);
          _startPolling();
        } else {
          _handleError(result['message'] ?? 'Error creating payment');
        }
      }
    } catch (e) {
      _handleError('Error processing payment: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Polling Logic
  void _startPolling() {
    _stopPolling();

    if (_orderId?.isEmpty ?? true) {
      _handleError('Order ID is missing');
      return;
    }

    _pollingTimer = Timer.periodic(_pollingDuration, (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      try {
        _order = await _paymentService.getOrderStatus(_orderId!);

        if (_order != null) {
          _handleOrderStatus(_order!.status);
        } else if (timer.tick >= _maxPollingAttempts) {
          timer.cancel();
          _handleError('Payment timeout');
        }
      } catch (e) {
        timer.cancel();
        _handleError('Error checking payment status: $e');
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // Order Status Handling
  void _handleOrderStatus(String? status) {
    if (!mounted || !_hasStartedPayment) return;

    switch (status?.toUpperCase()) {
      case 'COMPLETED':
        _stopPolling();
        // Thêm setState trước khi navigate
        setState(() {
          _isProcessing = false;
          _hasStartedPayment = false;
          _paypalUrl = null;
        });
        // Sử dụng pushAndRemoveUntil để clear stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => PaymentStatusScreen(
              status: 'success',
              amount: widget.amount,
              orderId: _orderId ?? '',
            ),
          ),
          (route) => false, // Xóa tất cả màn hình khác trong stack
        );
      case 'CREATED':
        _stopPolling();
        // Thêm setState trước khi navigate
        setState(() {
          _isProcessing = false;
          _hasStartedPayment = false;
          _paypalUrl = null;
        });
        // Sử dụng pushAndRemoveUntil để clear stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => PaymentStatusScreen(
              status: 'created',
              amount: widget.amount,
              orderId: _orderId ?? '',
            ),
          ),
          (route) => false, // Xóa tất cả màn hình khác trong stack
        );
        break;
    }
    if (status != null) {
      setState(() {
        _isProcessing = false;
        _hasStartedPayment = false;
        _paypalUrl = null;
      });
    }
  }

  void _handleError(String message) {
    _handleOrderStatus('error');
  }

  // UI Helper Methods
  Future<bool> _showCancelConfirmation() async {
    if (!_isProcessing) return true;

    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn hủy thanh toán?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Có'),
          ),
        ],
      ),
    );

    if (shouldCancel ?? false) {
      _stopPolling();
    }
    return shouldCancel ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán đơn hàng'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if (await _showCancelConfirmation()) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: WillPopScope(
        onWillPop: _showCancelConfirmation,
        child: _paypalUrl != null ? _buildWebView() : _buildCheckoutScreen(),
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.user == null) {
          return const SizedBox.shrink(); // Ẩn nếu chưa đăng nhập
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin giao hàng',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên người dùng
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          auth.user!.name,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Số điện thoại
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          auth.user!.phoneNumber!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Địa chỉ
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            auth.user!.address!,
                            style: Theme.of(context).textTheme.bodyLarge,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCheckoutScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần hiển thị sản phẩm
            _buildCartItemsList(),
            const Divider(height: 32),
            const SizedBox(height: 60),

            //Phần hiển thị địa chỉ, số điện thoại người dùng
            _buildUserInfoSection(),
            const SizedBox(height: 24),

            // Phần chọn phương thức thanh toán
            _buildPaymentMethods(),
            const SizedBox(height: 24),

            // Phần tổng tiền và nút thanh toán
            _buildOrderSummary(),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sản phẩm của bạn',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.cartItems.length,
          itemBuilder: (context, index) {
            final item = widget.cartItems[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: item.product.imageUrls.isNotEmpty
                    ? Image.network(
                        item.product.imageUrls.first,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.shopping_bag),
                title: Text(item.product.name),
                subtitle: Text(
                  '${_currencyFormatter.format(item.product.price)} x ${item.quantity}',
                ),
                trailing: Text(
                  _currencyFormatter.format(item.product.price * item.quantity),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phương thức thanh toán',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Text('Thanh toán khi nhận hàng'),
                value: 'cod',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() => _selectedPaymentMethod = value!);
                },
              ),
              RadioListTile<String>(
                title: Row(
                  children: [
                    const Text('Thanh toán qua PayPal  '),
                    Image.network(
                      'http://paypalobjects.com/webstatic/mktg/logo/pp_cc_mark_111x69.jpg',
                      height: 24,
                    ),
                  ],
                ),
                value: 'paypal',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() => _selectedPaymentMethod = value!);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng tiền:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  _formattedAmount,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 16),
              const Text(
                'Đang xử lý thanh toán...',
                textAlign: TextAlign.center,
              ),
            ] else
              ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _selectedPaymentMethod == 'cod'
                      ? 'Đặt hàng'
                      : 'Thanh toán qua PayPal',
                ),
              ),
            if (_orderId != null && _isProcessing) ...[
              const SizedBox(height: 8),
              Text(
                'Mã đơn hàng: $_orderId',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWebView() {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(_paypalUrl!)),
      onLoadStart: (controller, url) async {
        final urlStr = url.toString();

        // Kiểm tra URL đặc biệt từ server
        if (urlStr.startsWith('flutter://')) {
          // Ngăn WebView load URL này
          await controller.stopLoading();
          _stopPolling();
          setState(() {
            _isProcessing = false;
            _hasStartedPayment = false;
            _paypalUrl = null;
          });

          if (urlStr.contains('success')) {
            // Lấy orderId từ URL parameters nếu có
            final uri = Uri.parse(urlStr);
            final orderId = uri.queryParameters['paypalOrderId'];
            if (orderId != null) {
              _orderId = orderId;
            }
            _handleOrderStatus('success');
          } else if (urlStr.contains('cancel')) {
            _handleOrderStatus('cancelled');
          } else if (urlStr.contains('error')) {
            final uri = Uri.parse(urlStr);
            final message = uri.queryParameters['message'];
            _handleError(message ?? 'Payment error');
          }
        }
      },
      // Thêm cài đặt cho WebView
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          useOnLoadResource: true,
        ),
      ),
      // Xử lý override URL loading
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final url = navigationAction.request.url?.toString();
        if (url?.startsWith('flutter://') ?? false) {
          return NavigationActionPolicy.CANCEL;
        }
        return NavigationActionPolicy.ALLOW;
      },
    );
  }
}

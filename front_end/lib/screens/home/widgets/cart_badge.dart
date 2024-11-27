import 'package:flutter/material.dart';

class CartBadge extends StatelessWidget {
  final int itemCount;

  const CartBadge({
    super.key,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    // Chỉ hiển thị badge khi có sản phẩm trong giỏ hàng
    if (itemCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      child: Text(
        itemCount.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

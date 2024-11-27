import 'package:ecommerce_sneaker_app/models/product.dart';

class CartItem {
  final Product product;
  final String size;
  final String color;
  int quantity;

  CartItem({
    required this.product,
    required this.size,
    required this.color,
    required this.quantity,
  });

  double get total => product.isOnSale
      ? (product.salePrice ?? product.price) * quantity
      : product.price * quantity;
}

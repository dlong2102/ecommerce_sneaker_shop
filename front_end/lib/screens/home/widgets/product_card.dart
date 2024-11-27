import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/product.dart';
import '../../../providers/favorites_provider.dart';
import 'package:intl/intl.dart'; // Thêm package để format số

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  // Hàm format số theo định dạng tiền VND
  String formatCurrency(double amount) {
    final formatCurrency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'VNĐ',
      decimalDigits: 0,
    );
    return formatCurrency.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final isFavorite = favoritesProvider.isFavorite(product);
        return GestureDetector(
          onDoubleTap: () {
            if (isFavorite) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.red,
                  content: Text('Đã xóa khỏi danh sách yêu thích',
                      style: TextStyle(color: Colors.white)),
                  duration: Duration(seconds: 1),
                ),
              );
              favoritesProvider.removeFavorite(product);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.green,
                  content: Text('Đã thêm vào danh sách yêu thích',
                      style: TextStyle(color: Colors.white)),
                  duration: Duration(seconds: 1),
                ),
              );
              favoritesProvider.toggleFavorite(product);
            }
          },
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                // Product Image Container
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: product.isOnSale
                        ? const Color(0xFFFFE8E8)
                        : const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.network(
                    product.imageUrls.first,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Brand/Category
                      Text(
                        product.brand,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Price Row
                      Row(
                        children: [
                          if (product.isOnSale) ...[
                            Text(
                              formatCurrency(product.salePrice ?? 0),
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formatCurrency(product.price),
                              style: TextStyle(
                                color: Colors.grey[400],
                                decoration: TextDecoration.lineThrough,
                                fontSize: 14,
                              ),
                            ),
                          ] else
                            Text(
                              formatCurrency(product.price),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                //Favorite Button
                Container(
                  margin: const EdgeInsets.only(bottom: 70),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

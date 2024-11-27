import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../models/product.dart';
import '../home/widgets/product_card.dart';
import '../product/product_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  void onProductTap(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          product: product,
          onAddToCart: (product, size, color, quantity) {
            context
                .read<CartProvider>()
                .addToCart(product, size, color, quantity);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  backgroundColor: Colors.green,
                  content: Text('Đã thêm vào giỏ hàng',
                      style: TextStyle(color: Colors.white))),
            );
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _removeFromFavorites(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa khỏi danh sách yêu thích'),
        content: const Text(
            'Bạn có chắc chắn muốn xóa sản phẩm này khỏi danh sách yêu thích?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<FavoritesProvider>(context, listen: false)
                  .removeFavorite(product);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.red,
                  content: Text('Đã xóa khỏi danh sách yêu thích',
                      style: TextStyle(color: Colors.white)),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu thích', style: TextStyle(fontSize: 26)),
        backgroundColor: Colors.grey[100],
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          if (favoritesProvider.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chưa có sản phẩm yêu thích',
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: favoritesProvider.favorites.length,
            itemBuilder: (context, index) {
              final product = favoritesProvider.favorites[index];
              return Stack(
                children: [
                  ProductCard(
                    product: product,
                    onTap: () => onProductTap(product),
                  ),
                  Positioned(
                    right: 0.5,
                    top: 13,
                    child: IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      onPressed: () => _removeFromFavorites(context, product),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:ecommerce_sneaker_app/screens/home/widgets/brand_filter.dart';
import 'package:ecommerce_sneaker_app/screens/home/widgets/header.dart';
import 'package:ecommerce_sneaker_app/screens/home/widgets/product_grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../providers/cart_provider.dart';
import '../../screens/product/product_detail_screen.dart';
import 'widgets/banner_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _selectedBrand = 'All';
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _loadProducts() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = '';
      });
    }
    try {
      final products = await _productService.getProducts();
      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _navigateToProductDetail(Product product) {
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

  void _onBrandSelected(String? brand) {
    setState(() {
      _selectedBrand = brand!;
      _filteredProducts = _products
          .where((product) => brand == 'All' || product.brand == brand)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.05),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header(onSearch: _onSearch),
              const SizedBox(height: 20),
              const BannerSlider(),
              const SizedBox(height: 10),
              BrandFilter(
                selectedBrand: _selectedBrand,
                onBrandSelected: _onBrandSelected,
              ),
              const SizedBox(height: 10),
              const Text(
                'Featured products',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error.isNotEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_error),
                                ElevatedButton(
                                  onPressed: _loadProducts,
                                  child: const Text('Thử lại'),
                                ),
                              ],
                            ),
                          )
                        : ProductsGrid(
                            products: _filteredProducts,
                            onProductTap: _navigateToProductDetail,
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:ecommerce_sneaker_app/screens/auth/login_screen.dart';
import 'package:ecommerce_sneaker_app/screens/payment/payment_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import 'package:http/http.dart' as http;
import '../../providers/auth_provider.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _showDeleteDialog(String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: const Text('Bạn chắc chắn muốn xóa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
              _deleteProduct(productId); // Gọi hàm xóa với ID sản phẩm
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchProducts() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:5000/product'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          products = data.map((json) => Product.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _deleteProduct(String id) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token; // Giả sử có phương thức lấy token
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:5000/product/$id'),
        headers: {
          'Authorization': 'Bearer $token', // Thêm token vào header
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _fetchProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                'Product deleted successfully',
                style: TextStyle(color: Colors.white),
              )),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.shopping_bag), text: 'Sản phẩm'),
              Tab(icon: Icon(Icons.payment), text: 'Thanh toán'),
            ],
          ),
          actions: [
            // Logout button
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                context.read<AuthProvider>().signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
            // Add product button - only show in Product tab
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddProductScreen()),
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Product Tab
            ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  leading: Image.network(product.imageUrls.first, width: 50),
                  title: Text(product.name),
                  subtitle: Text('${product.price} VNĐ'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditProductScreen(product: product),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteDialog(product.id),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Payment Tab
            const PaymentListTab(),
          ],
        ),
      ),
    );
  }
}

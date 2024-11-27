import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';

class EditProductScreen extends StatefulWidget {
  final Product? product;

  const EditProductScreen({super.key, this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlsController;
  late TextEditingController _additionalImagesController;
  late TextEditingController _brandController;
  late TextEditingController _sizeController;
  late TextEditingController _colorController;
  late TextEditingController _salePriceController;
  bool _inStock = [true, false].elementAt(0);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _imageUrlsController =
        TextEditingController(text: widget.product?.imageUrls.join(', ') ?? '');
    _additionalImagesController = TextEditingController(
        text: widget.product?.additionalImages.join(', ') ?? '');
    _brandController = TextEditingController(text: widget.product?.brand ?? '');
    _sizeController =
        TextEditingController(text: widget.product?.sizes.join(', ') ?? '');
    _colorController =
        TextEditingController(text: widget.product?.colors.join(', ') ?? '');
    _salePriceController = TextEditingController(
        text: widget.product?.salePrice?.toString() ?? '');
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Lấy AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Kiểm tra đăng nhập và quyền admin
      if (!authProvider.isLoggedIn || !authProvider.isAdmin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need admin privileges to perform this action'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final sizes =
          _sizeController.text.split(',').map((e) => e.trim()).toList();
      final colors =
          _colorController.text.split(',').map((e) => e.trim()).toList();
      final imageUrls =
          _imageUrlsController.text.split(',').map((e) => e.trim()).toList();
      final additionalImages = _additionalImagesController.text.isEmpty
          ? []
          : _additionalImagesController.text
              .split(',')
              .map((e) => e.trim())
              .toList();

      final productData = {
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'description': _descriptionController.text,
        'imageUrl':
            imageUrls.first, // Send only the first image URL as a string
        'additionalImages': additionalImages,
        'brand': _brandController.text,
        'sizes': sizes,
        'colors': colors,
        'inStock': _inStock,
        'salePrice': double.parse(_salePriceController.text),
      };

      final url = widget.product == null
          ? '/product'
          : '/product/${widget.product!.id}';

      // Sử dụng authenticatedRequest từ AuthProvider
      final response = await authProvider.authenticatedRequest(
        url,
        method: 'PUT',
        body: productData,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product saved successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Failed to save product'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error saving product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while saving the product'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Sửa sản phẩm'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên sản phẩm',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Giá',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a price' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Thông tin',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageUrlsController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                border: OutlineInputBorder(),
              ),
              maxLength: 1000,
              maxLines: 5,
            ),
            TextFormField(
              controller: _additionalImagesController,
              decoration: const InputDecoration(
                labelText: 'Additional Images URLs',
                border: OutlineInputBorder(),
                hintText:
                    'Nhập các URL hình ảnh bổ sung, cách nhau bởi dấu phẩy',
              ),
              maxLength: 1000,
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: 'Thương hiệu',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sizeController,
              decoration: const InputDecoration(
                labelText: 'Sizes',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.isEmpty
                  ? 'Vui lòng nhập ít nhất một kích thước'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(
                labelText: 'Màu sắc',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Vui lòng nhập ít nhất một màu sắc' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('In Stock', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 16),
                Switch(
                  value: _inStock,
                  onChanged: (value) {
                    setState(() {
                      _inStock = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _salePriceController,
              decoration: const InputDecoration(
                labelText: 'Giá sale (Nếu có)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveProduct,
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';

class Header extends StatefulWidget {
  @override
  State<Header> createState() => _HeaderState();

  final void Function(String) onSearch;

  Header({required this.onSearch});
}

class _HeaderState extends State<Header> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Lấy thông tin user khi widget được khởi tạo
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<AuthProvider>(context, listen: false).getUserProfile();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Delivery Address',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          auth.user?.address ?? 'No address provided',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.black, fontSize: 16),
            decoration: InputDecoration(
              labelText: 'Search products',
              labelStyle: const TextStyle(color: Colors.black, fontSize: 16),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.black,
              ),
              fillColor: Colors.grey[200],
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            onChanged: (query) => widget.onSearch(query),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

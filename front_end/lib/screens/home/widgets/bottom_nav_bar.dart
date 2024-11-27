import 'package:ecommerce_sneaker_app/providers/cart_provider.dart';
import 'package:ecommerce_sneaker_app/screens/home/widgets/cart_badge.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'nav_bar_item.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    final cartItemCount = context.watch<CartProvider>().itemCount;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          NavBarItem(
            icon: Icons.home,
            isSelected: widget.selectedIndex == 0,
            onTap: () => widget.onItemTapped(0),
            badge: 0,
          ),
          NavBarItem(
            icon: Icons.shopping_bag,
            isSelected: widget.selectedIndex == 1,
            onTap: () => widget.onItemTapped(1),
            badge: CartBadge(itemCount: cartItemCount),
          ),
          NavBarItem(
            icon: Icons.favorite,
            isSelected: widget.selectedIndex == 2,
            onTap: () => widget.onItemTapped(2),
            badge: 0,
          ),
          NavBarItem(
            icon: Icons.person,
            isSelected: widget.selectedIndex == 3,
            onTap: () => widget.onItemTapped(3),
            badge: 0,
          ),
        ],
      ),
    );
  }
}

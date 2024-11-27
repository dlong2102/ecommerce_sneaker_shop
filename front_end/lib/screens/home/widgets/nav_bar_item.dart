import 'package:ecommerce_sneaker_app/screens/home/widgets/cart_badge.dart';
import 'package:flutter/material.dart';

class NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final dynamic badge;

  const NavBarItem({
    super.key,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isSelected ? Colors.orange : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black,
              size: 30,
            ),
          ),
          if (badge is Widget)
            Positioned(
              right: -5,
              top: -5,
              child: badge,
            )
          else if (badge is int && badge > 0)
            Positioned(
              right: -5,
              top: -5,
              child: CartBadge(itemCount: badge),
            ),
        ],
      ),
    );
  }
}

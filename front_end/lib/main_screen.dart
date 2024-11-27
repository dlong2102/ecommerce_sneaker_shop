import 'package:ecommerce_sneaker_app/screens/favorites/favorites_screen.dart';
import 'package:ecommerce_sneaker_app/screens/home/widgets/bottom_nav_bar.dart';
import 'package:ecommerce_sneaker_app/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_sneaker_app/screens/home/home_screen.dart';
import 'package:ecommerce_sneaker_app/screens/cart/cart_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(),
      const CartScreen(),
      const FavoritesScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'main_page.dart';
import 'wishlist_page.dart';
import 'details_screen.dart'; // Importando a tela de detalhes

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // Start at Home

  final List<Widget> _pages = [
    const WishlistPage(),
    const MainPage(),
    const Center(child: Text('Profile')), // Placeholder for Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
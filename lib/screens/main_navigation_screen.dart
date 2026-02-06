import 'package:flutter/material.dart';
import 'package:fridge_recipe/screens/home_screen.dart';
import 'package:fridge_recipe/screens/diet_screen.dart';
import 'package:fridge_recipe/screens/premium_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final String apiKey;
  const MainNavigationScreen({Key? key, required this.apiKey}) : super(key: key);

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(apiKey: widget.apiKey),
      const DietScreen(),
      const PremiumScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color(0xFF3B82F6),
          unselectedItemColor: const Color(0xFF9CA3AF),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: '냉장고'),
            BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'AI 식단'),
            BottomNavigationBarItem(icon: Icon(Icons.stars), label: '프리미엄'),
          ],
        ),
      ),
    );
  }
}

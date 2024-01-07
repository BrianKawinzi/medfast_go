import 'package:flutter/material.dart';
import 'package:medfast_go/business/products.dart';
import 'package:medfast_go/business/reports.dart';
import 'package:medfast_go/pages/general_page.dart';
import 'package:medfast_go/pages/home_page.dart';
import 'package:medfast_go/pages/home_screen.dart';
import 'package:medfast_go/pages/profile.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    Products(productName: ''),
    GeneralPage(),
    Reports(),
    PharmacyProfile(),
  ];

  // Explicitly define a PageController
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            // Jump to the corresponding page when a tab is tapped
            _pageController.jumpToPage(index);
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard, color: _currentIndex == 0 ? Colors.green : Colors.lightGreen),
            label: 'Board',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag, color: _currentIndex == 1 ? Colors.green : Colors.lightGreen),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps, color: _currentIndex == 2 ? Colors.green : Colors.lightGreen),
            label: 'General',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, color: _currentIndex == 3 ? Colors.green : Colors.lightGreen),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: _currentIndex == 4 ? Colors.green : Colors.lightGreen),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// lib/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:vouch_app/pages/home_page.dart';
import 'package:vouch_app/pages/profile_page.dart';
import 'package:vouch_app/pages/rewards_page.dart';
import 'package:vouch_app/pages/notifications_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  // PageController allows us to control the PageView for swiping and tapping
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    // We don't need setState here because the onPageChanged callback will handle it.
    // This makes the animation smoother.
    _pageController.animateToPage(
      index,
      // Updated duration and curve for a smoother feel.
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // This function is called when the user swipes between pages
  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged, // Updates the nav bar when swiping
        // The children are now stateful and will keep their state.
        children: const <Widget>[
          HomePage(),
          NotificationsPage(),
          RewardsPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications), label: 'Inbox'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard_outlined), activeIcon: Icon(Icons.card_giftcard), label: 'Rewards'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

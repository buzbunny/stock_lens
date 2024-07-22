import 'package:flutter/material.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'settings_page.dart';
import 'news.dart'; // Import your news page here
import 'watchList.dart'; // Import your watchlist page here

class CustomNavBar extends StatelessWidget {
  final ValueChanged<int> onTap;
  final int currentIndex;

  const CustomNavBar({
    required this.onTap,
    required this.currentIndex,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.black,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildNavItem(context, Icons.home, 0, Home()),
          _buildNavItem(context, Icons.search, 1, SearchPage()),
          _buildNavItem(context, Icons.article, 2, NewsPage()), // News icon
          _buildNavItem(context, Icons.bookmark, 3, WatchListPage()), // Watchlist icon
          _buildNavItem(context, Icons.settings, 4, SettingsPage()),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, int index, Widget page) {
    return IconButton(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: currentIndex == index ? EdgeInsets.all(8.0) : EdgeInsets.all(0.0),
        decoration: BoxDecoration(
          color: currentIndex == index ? Colors.white.withOpacity(0.2) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
      onPressed: () {
        onTap(index); // Notify parent widget
        _navigateTo(context, page);
      },
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}

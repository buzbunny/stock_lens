import 'package:flutter/material.dart';
import 'navbar.dart';


class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Text('Settings Page'),
      ),
      bottomNavigationBar: CustomNavBar(
        onTap: (index) {
          // Handle tap logic if needed
        },
        currentIndex: 2, // Set current index accordingly
      ),
    );
  }
}
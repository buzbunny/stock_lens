import 'package:flutter/material.dart';
import 'dart:io';
import 'navbar.dart';
import 'about_us.dart';
import 'terms_and_conditions.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isPushNotificationsEnabled = false;
  bool isBiometricEnabled = false;
  bool isDarkModeEnabled = false;

  Route createFadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOut;

        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return FadeTransition(
          opacity: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text(
            'Confirm Exit',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to close the app?',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
                // Close the app
                exit(0); // Use exit(0) to close the app
              },
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0),
        children: [
          const Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 70,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Jhon Abraham',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          ListTile(
            title: const Text(
              'Change profile data',
              style: TextStyle(color: Colors.white),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {
              // Handle change profile data action
            },
          ),
          SwitchListTile(
            title: const Text(
              'Push notifications',
              style: TextStyle(color: Colors.white),
            ),
            value: isPushNotificationsEnabled,
            activeColor: Colors.green,
            onChanged: (bool value) {
              setState(() {
                isPushNotificationsEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text(
              'Enable biometric',
              style: TextStyle(color: Colors.white),
            ),
            value: isBiometricEnabled,
            activeColor: Colors.green,
            onChanged: (bool value) {
              setState(() {
                isBiometricEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text(
              'Enable dark mode',
              style: TextStyle(color: Colors.white),
            ),
            value: isDarkModeEnabled,
            activeColor: Colors.green,
            onChanged: (bool value) {
              setState(() {
                isDarkModeEnabled = value;
              });
            },
          ),
          const Divider(color: Colors.white),
          ListTile(
            title: const Text(
              'About us',
              style: TextStyle(color: Colors.white),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {
              // Handle about us action
              Navigator.of(context).push(createFadeRoute(AboutUsPage()));
            },
          ),
          ListTile(
            title: const Text(
              'Terms and conditions',
              style: TextStyle(color: Colors.white),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {
              // Handle terms and conditions action
              Navigator.of(context).push(createFadeRoute(TermsAndConditions()));
            },
          ),
          ListTile(
            title: const Text(
              'Exit',
              style: TextStyle(color: Colors.white),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: _showLogoutConfirmationDialog,
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        onTap: (index) {
          // Handle tap logic if needed
        },
        currentIndex: 4,
      ),
    );
  }
}

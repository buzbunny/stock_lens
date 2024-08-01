// settings_page.dart

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'navbar.dart';
import 'about_us.dart';
import 'terms_and_conditions.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isPushNotificationsEnabled = false;
  bool isBiometricEnabled = false;
  bool isDarkModeEnabled = false;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Username not set';
    });
  }

  Future<void> _updateUsername(String newUsername) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', newUsername);
    setState(() {
      _username = newUsername;
    });
  }

  void _showEditUsernameDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    TextEditingController _usernameController = TextEditingController(text: _username);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.primary,
          title: Text(
            'Edit Username',
            style: TextStyle(color: colorScheme.onBackground),
          ),
          content: TextField(
            controller: _usernameController,
            style: TextStyle(color: colorScheme.onBackground),
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colorScheme.onBackground.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colorScheme.primary),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                _updateUsername(_usernameController.text);
                Navigator.of(context).pop();
              },
              child: Text(
                'Save',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

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
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.primary,
          title: Text(
            'Confirm Exit',
            style: TextStyle(color: colorScheme.onBackground),
          ),
          content: Text(
            'Are you sure you want to close the app?',
            style: TextStyle(color: colorScheme.onBackground),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: colorScheme.error),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                exit(0); // Use exit(0) to close the app
              },
              child: Text(
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: colorScheme.onBackground,
          ),
        ),
        backgroundColor: colorScheme.background,
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: colorScheme.secondary,
                  child: Icon(
                    Icons.person,
                    size: 70,
                    color: colorScheme.onSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _username,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: colorScheme.onBackground),
                      onPressed: _showEditUsernameDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          ListTile(
            title: Text(
              'About us',
              style: TextStyle(color: colorScheme.onBackground),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: colorScheme.onBackground),
            onTap: () {
              Navigator.of(context).push(createFadeRoute(AboutUsPage()));
            },
          ),
          ListTile(
            title: Text(
              'Terms and conditions',
              style: TextStyle(color: colorScheme.onBackground),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: colorScheme.onBackground),
            onTap: () {
              Navigator.of(context).push(createFadeRoute(TermsAndConditions()));
            },
          ),
          ListTile(
            title: Text(
              'Exit',
              style: TextStyle(color: colorScheme.onBackground),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: colorScheme.onBackground),
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

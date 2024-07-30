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
    TextEditingController _usernameController = TextEditingController(text: _username);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text(
            'Edit Username',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: _usernameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
            ),
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
                _updateUsername(_usernameController.text);
                Navigator.of(context).pop();
              },
              child: const Text(
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
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 70,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: _showEditUsernameDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // SwitchListTile(
          //   title: const Text(
          //     'Enable dark mode',
          //     style: TextStyle(color: Colors.white),
          //   ),
          //   value: isDarkModeEnabled,
          //   activeColor: Colors.green,
          //   onChanged: (bool value) {
          //     setState(() {
          //       isDarkModeEnabled = value;
          //     });
          //   },
          // ),
          // const Divider(color: Colors.white),
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

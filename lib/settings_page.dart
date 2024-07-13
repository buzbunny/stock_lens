import 'package:flutter/material.dart';
import 'navbar.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isPushNotificationsEnabled = false;
  bool isBiometricEnabled = false;
  bool isDarkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
            },
          ),
          ListTile(
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {
              // Handle logout action
            },
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        onTap: (index) {
          // Handle tap logic if needed
        },
        currentIndex: 2,
      ),
    );
  }
}

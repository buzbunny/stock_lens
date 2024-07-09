import 'package:flutter/material.dart';
import 'navbar.dart';

class SettingsPage extends StatelessWidget {
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
        backgroundColor: Colors.black, // Ensure the app bar color matches the dark mode theme
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0), // Reduced top padding
        children: [
          const Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/img2.jpg'),
                ),
                SizedBox(height: 10),
                Text(
                  'Jhon Abraham',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Text color set to white
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          ListTile(
            title: const Text(
              'Change password',
              style: TextStyle(color: Colors.white), // Text color set to white
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white), // Icon color set to white
            onTap: () {
              // Handle change password action
            },
          ),
          SwitchListTile(
            title: const Text(
              'Push notifications',
              style: TextStyle(color: Colors.white), // Text color set to white
            ),
            value: false, // Replace with your push notifications state
            activeColor: const Color.fromARGB(255, 183, 66, 91),
            onChanged: (bool value) {
              // Handle toggle push notifications
            },
          ),
          SwitchListTile(
            title: const Text(
              'Enable biometric',
              style: TextStyle(color: Colors.white), // Text color set to white
            ),
            value: false, // Replace with your biometric enabled state
            activeColor: const Color.fromARGB(255, 183, 66, 91),
            onChanged: (bool value) {
              // Handle toggle biometric enabled
            },
          ),
          SwitchListTile(
            title: const Text(
              'Enable dark mode',
              style: TextStyle(color: Colors.white), // Text color set to white
            ),
            value: false, // Replace with your biometric enabled state
            activeColor: const Color.fromARGB(255, 183, 66, 91),
            onChanged: (bool value) {
              // Handle toggle biometric enabled
            },
          ),
          const Divider(color: Colors.white), // Divider color set to white
          ListTile(
            title: const Text(
              'About us',
              style: TextStyle(color: Colors.white), // Text color set to white
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white), // Icon color set to white
            onTap: () {
              // Handle about us action
            },
          ),
          ListTile(
            title: const Text(
              'Terms and conditions',
              style: TextStyle(color: Colors.white), // Text color set to white
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white), // Icon color set to white
            onTap: () {
              // Handle terms and conditions action
            },
          ),
          ListTile(
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.white), // Text color set to white
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white), // Icon color set to white
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
        currentIndex: 2, // Set current index accordingly
      ),
    );
  }
}

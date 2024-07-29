import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _fullNameController = TextEditingController();
  bool _isFullNameValid = false;

  bool get _isFormValid {
    return _isFullNameValid;
  }

  void _onFormFieldChanged() {
    setState(() {
      _isFullNameValid = _validateFullName(_fullNameController.text);
    });
  }

  bool _validateFullName(String value) {
    // Ensure the name doesn't start with a number or contain special characters
    return RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$').hasMatch(value);
  }

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(_onFormFieldChanged);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setBool('isRegistered', true);  // Set isRegistered to true
  }

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
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/logo-login.png',
            height: 200,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Get Started',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Stack(
                children: [
                  TextField(
                    controller: _fullNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      errorText: !_isFullNameValid && _fullNameController.text.isNotEmpty
                          ? 'Username should start with a letter and contain only letters, numbers, and underscores'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isFormValid
                    ? () async {
                        await _saveUsername(_fullNameController.text);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => Home()),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid ? Colors.green : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
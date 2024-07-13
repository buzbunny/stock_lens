import 'package:flutter/material.dart';
import 'login.dart'; // Make sure to have login.dart file in the same directory

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreePrivacyPolicy = false;
  bool _agreeMarketingMessages = false;

  bool _showPasswordRequirements = false;
  bool _isMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool get _doPasswordsMatch => _passwordController.text == _confirmPasswordController.text;

  bool _isFullNameValid = true;
  bool _isEmailValid = true;

  bool get _isFormValid {
    return _isFullNameValid &&
        _isEmailValid &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _agreePrivacyPolicy &&
        _agreeMarketingMessages &&
        _doPasswordsMatch &&
        _isMinLength &&
        _hasUppercase &&
        _hasLowercase &&
        _hasNumber &&
        _hasSpecialChar;
  }

  void _onFormFieldChanged() {
    setState(() {
      _isFullNameValid = _validateFullName(_fullNameController.text);
      _isEmailValid = _validateEmail(_emailController.text);

      _isMinLength = _passwordController.text.length >= 8;
      _hasUppercase = _passwordController.text.contains(RegExp(r'[A-Z]'));
      _hasLowercase = _passwordController.text.contains(RegExp(r'[a-z]'));
      _hasNumber = _passwordController.text.contains(RegExp(r'\d'));
      _hasSpecialChar = _passwordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  bool _validateFullName(String value) {
    // Allow letters and underscores, but not spaces
    return RegExp(r'^[a-zA-Z_]+$').hasMatch(value);
  }

  bool _validateEmail(String value) {
    // Basic email validation pattern
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value);
  }

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(_onFormFieldChanged);
    _emailController.addListener(_onFormFieldChanged);
    _passwordController.addListener(_onFormFieldChanged);
    _confirmPasswordController.addListener(_onFormFieldChanged);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Handle back button press
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
                      labelText: ' Username',
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      errorText: !_isFullNameValid && _fullNameController.text.isNotEmpty
                          ? 'Username should only contain letters and underscores'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Stack(
                children: [
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      errorText: !_isEmailValid && _emailController.text.isNotEmpty
                          ? 'Enter a valid email address'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Focus(
                onFocusChange: (hasFocus) {
                  setState(() {
                    _showPasswordRequirements = hasFocus;
                  });
                },
                child: TextField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    suffixIcon: Icon(Icons.visibility_off, color: Colors.white),
                  ),
                  obscureText: true,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  suffixIcon: Icon(Icons.visibility_off, color: Colors.white),
                ),
                obscureText: true,
              ),
              if (!_doPasswordsMatch)
                const Text(
                  'Both passwords must match',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              if (_showPasswordRequirements) ...[
                const SizedBox(height: 20),
                const Text(
                  'Password must contain:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                PasswordRequirement(
                  text: 'Min 8 Characters',
                  isMet: _isMinLength,
                ),
                PasswordRequirement(
                  text: 'Upper-case Letter',
                  isMet: _hasUppercase,
                ),
                PasswordRequirement(
                  text: 'Lower-case Letter',
                  isMet: _hasLowercase,
                ),
                PasswordRequirement(
                  text: 'Number',
                  isMet: _hasNumber,
                ),
                PasswordRequirement(
                  text: 'Special Character',
                  isMet: _hasSpecialChar,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _agreePrivacyPolicy,
                    onChanged: (value) {
                      setState(() {
                        _agreePrivacyPolicy = value ?? false;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  const Expanded(
                    child: Text(
                      'By registering you agree to the Privacy and Membership Policies.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _agreeMarketingMessages,
                    onChanged: (value) {
                      setState(() {
                        _agreeMarketingMessages = value ?? false;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  const Expanded(
                    child: Text(
                      'I understand that tabii may send me marketing messages.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isFormValid
                    ? () {
                        // Implement registration functionality
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
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
                    'Create Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
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

class PasswordRequirement extends StatelessWidget {
  final String text;
  final bool isMet;

  const PasswordRequirement({
    required this.text,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check : Icons.close,
          color: isMet ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: isMet ? Colors.green : Colors.red),
        ),
      ],
    );
  }
}

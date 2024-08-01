import 'package:flutter/material.dart';

class TermsAndConditions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background, // Set entire page background color
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40.0), // Push the image up more
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onBackground),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Center(
                child: Image.asset(
                  'assets/logo-white.png',
                  height: 150.0, // Increase the height of the image
                ),
              ),
              const SizedBox(height: 20.0), // Adjust spacing between image and text
              Text(
                'Terms and Conditions\n\nWelcome to StockLens\n\nThese Terms and Conditions (Terms) govern your access to and use of the StockLens mobile application (App) provided by StockLens Ltd ("Company"). By accessing or using our App, you agree to be bound by these Terms. If you disagree with any part of these Terms, you may not access the App.\n\n1. Use of the App\n\n   1.1. You must be at least 18 years old to use the App.\n   1.2. You agree to use the App only for lawful purposes and in accordance with these Terms.\n\n2. User Accounts\n\n   2.1. To access certain features of the App, you may be required to create an account. You are responsible for maintaining the confidentiality of your account and password.\n   2.2. You agree to provide accurate, current, and complete information during the registration process and to update such information to keep it accurate, current, and complete.\n\n3. Privacy\n\n   3.1. Your privacy is important to us. Please refer to our Privacy Policy to understand how we collect, use, and disclose information about you.\n\n4. Intellectual Property\n\n   4.1. The App and its original content, features, and functionality are owned by StockLens Ltd and are protected by international copyright, trademark, patent, trade secret, and other intellectual property or proprietary rights laws.\n\n5. Disclaimer\n\n   5.1. The App is provided "as is" and "as available" without warranties of any kind, whether express or implied.\n\n6. Limitation of Liability\n\n   6.1. In no event shall StockLens Ltd, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, arising out of or in connection with your use of the App.\n\n7. Governing Law\n\n   7.1. These Terms shall be governed by and construed in accordance with the laws of [Your Country], without regard to its conflict of law provisions.\n\n8. Changes to Terms\n\n   8.1. StockLens Ltd reserves the right, at its sole discretion, to modify or replace these Terms at any time. If a revision is material, we will provide at least 30 days\' notice prior to any new terms taking effect.\n\n9. Contact Us\n\n   9.1. If you have any questions about these Terms, please contact us at [support email].\n\nBy downloading, installing, or using the StockLens App, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.\n\nWelcome to StockLens.',
                style: TextStyle(
                  color: colorScheme.onBackground,
                  fontSize: 18.0, // Increase font size for better readability
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 500.0), // Adjust the height for ample scrolling space
            ],
          ),
        ),
      ),
    );
  }
}

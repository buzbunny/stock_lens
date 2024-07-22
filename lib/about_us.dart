import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 0, 0), // Set entire page background color
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 40.0, // Push the image up more
              ),
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
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
              const Text(
                'About Us\n\nWelcome to StockLens\n\nAt StockLens, we understand that the world of stock trading can be both exciting and daunting. Our mission is to empower you with the tools and insights you need to confidently monitor and analyze your favorite stocks before you take the leap with your preferred brokers.\n\nWho We Are\n\nStockLens is a cutting-edge platform dedicated to providing investors with real-time data, comprehensive analytics, and personalized tracking features. Whether you\'re a seasoned trader or just starting out, our goal is to make stock monitoring accessible, informative, and user-friendly.\n\nOur Vision\n\nWe believe in democratizing financial information and providing everyone with the opportunity to make informed investment decisions. StockLens is designed to bridge the gap between raw data and actionable insights, helping you stay ahead in the dynamic world of stock markets.\n\nWhat We Offer\n\n- Real-Time Monitoring: Stay updated with the latest stock prices, market trends, and financial news.\n- Comprehensive Analytics: Gain deeper insights with our advanced charts, historical data, and performance metrics.\n- Personalized Watchlists: Create and manage watchlists tailored to your investment interests and strategies.\n- Custom Alerts: Set up notifications for price changes, news updates, and other critical events affecting your stocks.\n- User-Friendly Interface: Navigate through our intuitive platform with ease, whether you\'re on your computer or mobile device.\n\nWhy Choose StockLens?\n\nStockLens is more than just a monitoring tool—it\'s your companion in the journey of stock trading. We are committed to providing a reliable, secure, and insightful experience that enhances your investment strategies and helps you make smarter financial decisions.\n\nJoin Us\n\nEmbark on a new era of stock monitoring with StockLens. Connect with us today and take the first step towards mastering your investments. With StockLens, you\'re always one step ahead in the stock market game.\n\n---\n\nContact Us\n\nHave questions or need assistance? Our support team is here to help! Reach out to us at [support email] or follow us on [social media links].\n\nWelcome to the future of stock monitoring. Welcome to StockLens.',
                style: TextStyle(
                  color: Colors.white,
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

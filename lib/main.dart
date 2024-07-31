import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'api_call_manager.dart';
import 'watchlist_manager.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'login.dart';
import 'register.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
// import 'back_service.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await initializeBackgroundService();

  HttpOverrides.global = MyHttpOverrides();

  final prefs = await SharedPreferences.getInstance();
  final bool isRegistered = prefs.getBool('isRegistered') ?? false;

  await _requestNotificationPermission();

  runApp(MyApp(isRegistered: isRegistered));
}

// Future<void> initializeBackgroundService() async {
//   await initializeService(
//     notificationTitle: 'News Update',
//     notificationContent: 'Fetching latest news',
//     intervalSeconds: 60, // Fetch news every hour
//     autoStart: true,
//     isForegroundMode: true,
//   );
// }

Future<void> _requestNotificationPermission() async {
  final prefs = await SharedPreferences.getInstance();
  final bool isNotificationPermissionRequested =
      prefs.getBool('isNotificationPermissionRequested') ?? false;

  if (!isNotificationPermissionRequested) {
    await Permission.notification.request();
    await prefs.setBool('isNotificationPermissionRequested', true);
  }
}

class MyApp extends StatelessWidget {
  final bool isRegistered;

  const MyApp({Key? key, required this.isRegistered}) : super(key: key);

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset(0.0, 0.0);
        const curve = Curves.ease;

        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ApiCallManager()),
        ChangeNotifierProvider(create: (context) => WatchlistManager()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          dividerColor: const Color.fromARGB(255, 52, 52, 52),
          extensions: const [
            PullDownButtonTheme(
              dividerTheme: PullDownMenuDividerTheme(
                dividerColor: Color.fromARGB(255, 21, 21, 21),
                largeDividerColor: Color.fromARGB(255, 21, 21, 21),
              ),
              routeTheme: PullDownMenuRouteTheme(
                backgroundColor: Color.fromARGB(255, 31, 31, 31),
              ),
              itemTheme: PullDownMenuItemTheme(
                destructiveColor: Colors.red,
                textStyle: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
          ),
          dividerTheme: const DividerThemeData(
            thickness: 0.8,
            color: Color.fromARGB(255, 52, 52, 52),
          ),
          primaryColor: const Color.fromARGB(255, 78, 172, 248),
        ),
        home: isRegistered ? Home() : LandingPage(),
        routes: {
          '/home': (context) => Home(),
          '/search': (context) => SearchPage(),
          '/register': (context) => RegisterPage(),
          '/login': (context) => LoginPage(),
        },
      ),
    );
  }
}

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final List<String> imgList = [
    'assets/img1.avif',
    'assets/img2.jpg',
    'assets/img3.avif',
  ];

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset(0.0, 0.0);
        const curve = Curves.ease;

        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              aspectRatio: 9 / 16,
              enlargeCenterPage: true,
              viewportFraction: 1.0,
              height: MediaQuery.of(context).size.height,
            ),
            items: imgList
                .map((item) => Container(
                      child: Center(
                        child: Image.asset(item,
                            fit: BoxFit.cover,
                            width: 1000,
                            height: double.infinity),
                      ),
                    ))
                .toList(),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black,
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Empower Your Investments with Real-Time Insights',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Discover the Power of Stocks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 15),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

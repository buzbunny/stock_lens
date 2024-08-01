import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'noti.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initializeService({
  required String notificationTitle,
  required String notificationContent,
  required int intervalSeconds,
  bool autoStart = true,
  bool isForegroundMode = true,
}) async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: isForegroundMode,
      autoStart: autoStart,
      notificationChannelId: 'your_channel_id',
      initialNotificationTitle: notificationTitle,
      initialNotificationContent: notificationContent,
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: autoStart,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized

  String title = "Default Title";
  String content = "Default Content";
  int intervalSeconds = 60;

  service.on('setNotificationData').listen((event) {
    title = event?['title'] ?? title;
    content = event?['content'] ?? content;
    intervalSeconds = event?['intervalSeconds'] ?? intervalSeconds;
  });

  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: title,
      content: content,
    );
  }

  Timer.periodic(Duration(seconds: intervalSeconds), (timer) async {
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: title,
        content: content,
      );
    }

    await fetchNewsAndUpdateNotification();

    print("Background service running with title: $title, content: $content");
    service.invoke('update');
  });
}

Future<void> fetchNewsAndUpdateNotification() async {
  const apiKey = 'cq9f34pr01qlu7f2mbh0cq9f34pr01qlu7f2mbhg';
  final response = await http.get(
    Uri.parse('https://finnhub.io/api/v1/news?category=general'),
    headers: {'X-Finnhub-Token': apiKey},
  );

  if (response.statusCode == 200) {
    final List<dynamic> newArticles = json.decode(response.body);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> oldArticles = prefs.getStringList('news') ?? [];

    List<String> newHeadlines = newArticles.map((article) => article['headline'].toString()).toList();
    List<String> uniqueNewArticles = newHeadlines.where((headline) => !oldArticles.contains(headline)).toList();

    // Update the stored news with the new headlines
    prefs.setStringList('news', [...oldArticles, ...uniqueNewArticles]);

    // Show notifications for new articles
    for (var i = 0; i < math.min(5, uniqueNewArticles.length); i++) {
      var article = newArticles.firstWhere((article) => article['headline'] == uniqueNewArticles[i]);
      Noti.showBigTextNotification(
        id: i,
        title: article['headline'],
        body: article['summary'] ?? 'No summary available',
        fln: flutterLocalNotificationsPlugin,
      );
    }
  } else {
    print('Failed to load news: ${response.statusCode}');
  }
}

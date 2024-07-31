// back_service.dart
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'noti.dart'; 
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  String title = "Default Title";
  String content = "Default Content";
  int intervalSeconds = 360;

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
    final List<dynamic> data = json.decode(response.body);
    List newArticles = [];

    for (var article in data) {
      newArticles.add(article);
    }

    for (var i = 0; i < math.min(5, newArticles.length); i++) {
      var article = newArticles[i];
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

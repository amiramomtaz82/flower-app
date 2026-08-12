import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';



Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {


  print('Handling a background message: ${message.messageId}');
}

class Fcm {
  static final FirebaseMessaging messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin
  flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel channel =
  AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  static Future<void> initialize() async {


    await requestPermission();


    await initLocalNotification();


    await onForegroundMessage();


    await getToken();

  }

  static Future<String?> getToken() async {
  ;

    final token = await messaging.getToken();

    print('========== FCM TOKEN ==========');
    print(token);

    return token;
  }

  static Future<void> requestPermission() async {
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print(
      'Notification permission: ${settings.authorizationStatus}',
    );
  }

  static Future<void> initLocalNotification() async {
    const androidSettings =
    AndroidInitializationSettings('@drawable/ic_notification');

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> onForegroundMessage() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('====== FOREGROUND MESSAGE ======');
      print('Notification: ${message.notification}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');

      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription:
              'This channel is used for important notifications.',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@drawable/ic_notification',
            ),
          ),
        );
      }
    });
  }
}
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
    ) async {
  print('Handling a background message: ${message.messageId}');
}

@singleton
class Fcm {
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin;

  Fcm(
      this._messaging,
      this._localNotificationsPlugin,
      );

  static const AndroidNotificationChannel channel =
  AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  Future<void> initialize() async {
    await requestPermission();
    await initLocalNotification();
    await onForegroundMessage();
    await getToken();
  }

  Future<String?> getToken() async {
    final token = await _messaging.getToken();

    print('========== FCM TOKEN ==========');
    print(token);

    return token;
  }

  Future<void> requestPermission() async {
    final settings = await _messaging.requestPermission(
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

  Future<void> initLocalNotification() async {
    const androidSettings =
    AndroidInitializationSettings('@drawable/ic_notification');

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> onForegroundMessage() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('====== FOREGROUND MESSAGE ======');
      print('Notification: ${message.notification}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');

      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotificationsPlugin.show(
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
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';

import 'local_notification_service.dart';

Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
    ) async {
  print('Handling a background message: ${message.messageId}');
}

@singleton
class Fcm {
  final FirebaseMessaging _messaging;
  final LocalNotificationService _localNotificationService;

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  Fcm(
      this._messaging,
      this._localNotificationService,
      );

  Future<void> initialize() async {
    await requestPermission();

    await _localNotificationService.initialize();

    await onForegroundMessage();

    await onTokenRefresh();

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

  Future<void> onForegroundMessage() async {
    await _foregroundSubscription?.cancel();

    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) async {
        print('====== FOREGROUND MESSAGE ======');
        print('Notification: ${message.notification}');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
        print('Data: ${message.data}');
        final notification = message.notification;
        final android = notification?.android;

        if (notification != null && android != null) {
          await _localNotificationService.showNotification(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
          );
        }
      },
    );
  }

  Future<void> onTokenRefresh() async {
    await _tokenRefreshSubscription?.cancel();

    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(
          (newToken) {
        print('========== FCM TOKEN REFRESHED ==========');
        print(newToken);

        // Save/update token here if you have local storage for it.
        // Notify backend if required.
      },
    );
  }

  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _tokenRefreshSubscription?.cancel();

    _foregroundSubscription = null;
    _tokenRefreshSubscription = null;
  }
}
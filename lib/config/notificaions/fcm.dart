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

  Fcm(
      this._messaging,
      this._localNotificationService,
      );

  // Expose stream for FcmTokenSyncService to handle backend syncing
  Stream<String> get onTokenRefreshStream => _messaging.onTokenRefresh;

  Future<void> initialize() async {
    // 1. Initialize local notification display channel
    await _localNotificationService.initialize();

    // 2. Listen to incoming foreground messages
    await onForegroundMessage();

    // Note: Do NOT call requestPermission() here per design specification[cite: 1]
  }

  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      return token;
    } catch (e) {
      print('Failed to get FCM token: $e');
      return null;
    }
  }

  // Trigger this explicitly from HomeScreen or Profile toggle[cite: 1]
  Future<NotificationSettings> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('Notification permission: ${settings.authorizationStatus}');
    return settings;
  }

  Future<void> onForegroundMessage() async {
    await _foregroundSubscription?.cancel();

    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) async {
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

  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    _foregroundSubscription = null;
  }
}
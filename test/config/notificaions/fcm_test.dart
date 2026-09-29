import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flower_app/config/notificaions/fcm.dart';
import 'package:flower_app/config/notificaions/local_notification_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockLocalNotificationService extends Mock
    implements LocalNotificationService {}

class MockNotificationSettings extends Mock implements NotificationSettings {}

void main() {
  late MockFirebaseMessaging mockMessaging;
  late MockLocalNotificationService mockLocalNotificationService;
  late FcmService fcmService;

  setUp(() {
    mockMessaging = MockFirebaseMessaging();
    mockLocalNotificationService = MockLocalNotificationService();
    fcmService = FcmService(mockMessaging, mockLocalNotificationService);
  });

  tearDown(() async {
    await fcmService.dispose();
  });

  group('FcmService.onTokenRefreshStream', () {
    test('returns the onTokenRefresh stream from FirebaseMessaging', () {
      final streamController = StreamController<String>.broadcast();
      when(() => mockMessaging.onTokenRefresh)
          .thenAnswer((_) => streamController.stream);

      final stream = fcmService.onTokenRefreshStream;

      expect(stream, equals(streamController.stream));
      streamController.close();
    });
  });

  group('FcmService.getToken', () {
    const testToken = 'mock_fcm_token_123';

    test('returns token when FirebaseMessaging.getToken succeeds', () async {
      when(() => mockMessaging.getToken()).thenAnswer((_) async => testToken);

      final token = await fcmService.getToken();

      expect(token, equals(testToken));
      verify(() => mockMessaging.getToken()).called(1);
    });

    test('returns null and catches exception when FirebaseMessaging.getToken throws',
        () async {
      when(() => mockMessaging.getToken())
          .thenThrow(Exception('Failed to retrieve token'));

      final token = await fcmService.getToken();

      expect(token, isNull);
      verify(() => mockMessaging.getToken()).called(1);
    });
  });

  group('FcmService.requestPermission', () {
    test(
        'requests permission with specified parameters and returns NotificationSettings',
        () async {
      final mockSettings = MockNotificationSettings();
      when(() => mockSettings.authorizationStatus)
          .thenReturn(AuthorizationStatus.authorized);

      when(() => mockMessaging.requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          )).thenAnswer((_) async => mockSettings);

      final result = await fcmService.requestPermission();

      expect(result, equals(mockSettings));
      expect(result.authorizationStatus, equals(AuthorizationStatus.authorized));
      verify(() => mockMessaging.requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          )).called(1);
    });
  });

  group('FcmService.initialize', () {
    test('initializes LocalNotificationService and attaches foreground listener',
        () async {
      when(() => mockLocalNotificationService.initialize())
          .thenAnswer((_) async {});

      await fcmService.initialize();

      verify(() => mockLocalNotificationService.initialize()).called(1);
    });
  });

  group('FcmService.dispose', () {
    test('cancels active subscription without throwing', () async {
      when(() => mockLocalNotificationService.initialize())
          .thenAnswer((_) async {});

      await fcmService.initialize();
      await expectLater(fcmService.dispose(), completes);
    });
  });
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flower_app/config/notificaions/fcm.dart';
import 'package:flower_app/features/auth/domain/repo/auth_repo.dart';
import 'package:flower_app/features/notifications/domain/usecase/sync_notification_permission_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepo extends Mock implements AuthRepo {}

class MockFcmService extends Mock implements FcmService {}

class MockNotificationSettings extends Mock implements NotificationSettings {}

void main() {
  late MockAuthRepo mockAuthRepo;
  late MockFcmService mockFcm;
  late MockNotificationSettings mockSettings;
  late SyncNotificationPermissionUseCase useCase;

  setUp(() {
    SyncNotificationPermissionUseCase.resetSession();
    mockAuthRepo = MockAuthRepo();
    mockFcm = MockFcmService();
    mockSettings = MockNotificationSettings();

    useCase = SyncNotificationPermissionUseCase(
      mockAuthRepo,
      mockFcm,
    );
  });

  group('SyncNotificationPermissionUseCase', () {
    test('returns null and skips request when already checked this session', () async {
      when(() => mockAuthRepo.getNotificationsEnabled())
          .thenAnswer((_) async => true);
      when(() => mockFcm.requestPermission())
          .thenAnswer((_) async => mockSettings);
      when(() => mockSettings.authorizationStatus)
          .thenReturn(AuthorizationStatus.authorized);

      // First call -> checks
      final firstResult = await useCase();
      expect(firstResult, AuthorizationStatus.authorized);

      // Second call in same session -> guarded
      final secondResult = await useCase();
      expect(secondResult, isNull);

      verify(() => mockAuthRepo.getNotificationsEnabled()).called(1);
      verify(() => mockFcm.requestPermission()).called(1);
    });

    test('bypasses session guard when forceCheck is true', () async {
      when(() => mockAuthRepo.getNotificationsEnabled())
          .thenAnswer((_) async => true);
      when(() => mockFcm.requestPermission())
          .thenAnswer((_) async => mockSettings);
      when(() => mockSettings.authorizationStatus)
          .thenReturn(AuthorizationStatus.authorized);

      await useCase();
      final forcedResult = await useCase(forceCheck: true);

      expect(forcedResult, AuthorizationStatus.authorized);
      verify(() => mockAuthRepo.getNotificationsEnabled()).called(2);
      verify(() => mockFcm.requestPermission()).called(2);
    });

    test('returns null without requesting permission when app-level notifications are disabled', () async {
      when(() => mockAuthRepo.getNotificationsEnabled())
          .thenAnswer((_) async => false);

      final result = await useCase();

      expect(result, isNull);
      verify(() => mockAuthRepo.getNotificationsEnabled()).called(1);
      verifyZeroInteractions(mockFcm);
      verifyNever(() => mockAuthRepo.saveNotificationsEnabled(any()));
    });

    test('requests permission and does NOT overwrite saveNotificationsEnabled when permission is denied', () async {
      when(() => mockAuthRepo.getNotificationsEnabled())
          .thenAnswer((_) async => true);
      when(() => mockFcm.requestPermission())
          .thenAnswer((_) async => mockSettings);
      when(() => mockSettings.authorizationStatus)
          .thenReturn(AuthorizationStatus.denied);

      final result = await useCase();

      expect(result, AuthorizationStatus.denied);
      verify(() => mockAuthRepo.getNotificationsEnabled()).called(1);
      verify(() => mockFcm.requestPermission()).called(1);

      // Critical check: OS denial must NEVER overwrite user preference!
      verifyNever(() => mockAuthRepo.saveNotificationsEnabled(any()));
    });

    test('requests permission and returns authorized status without touching saveNotificationsEnabled', () async {
      when(() => mockAuthRepo.getNotificationsEnabled())
          .thenAnswer((_) async => true);
      when(() => mockFcm.requestPermission())
          .thenAnswer((_) async => mockSettings);
      when(() => mockSettings.authorizationStatus)
          .thenReturn(AuthorizationStatus.authorized);

      final result = await useCase();

      expect(result, AuthorizationStatus.authorized);
      verify(() => mockAuthRepo.getNotificationsEnabled()).called(1);
      verify(() => mockFcm.requestPermission()).called(1);
      verifyNever(() => mockAuthRepo.saveNotificationsEnabled(any()));
    });
  });
}

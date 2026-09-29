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
  late MockFcmService mockFcmService;
  late SyncNotificationPermissionUseCase useCase;

  setUp(() {
    SyncNotificationPermissionUseCase.resetSession();
    mockAuthRepo = MockAuthRepo();
    mockFcmService = MockFcmService();
    useCase = SyncNotificationPermissionUseCase(mockAuthRepo, mockFcmService);
  });

  tearDown(() {
    SyncNotificationPermissionUseCase.resetSession();
  });

  group('SyncNotificationPermissionUseCase', () {
    test(
        'should request permission and return status when notifications are enabled at app-level',
        () async {
      final mockSettings = MockNotificationSettings();
      when(() => mockSettings.authorizationStatus)
          .thenReturn(AuthorizationStatus.authorized);
      when(() => mockAuthRepo.getNotificationsEnabled())
          .thenAnswer((_) async => true);
      when(() => mockFcmService.requestPermission())
          .thenAnswer((_) async => mockSettings);

      final status = await useCase();

      expect(status, equals(AuthorizationStatus.authorized));
      verify(() => mockAuthRepo.getNotificationsEnabled()).called(1);
      verify(() => mockFcmService.requestPermission()).called(1);
    });

    test(
        'should return null and not request FCM permission when app-level notifications are disabled',
        () async {
      when(() => mockAuthRepo.getNotificationsEnabled())
          .thenAnswer((_) async => false);

      final status = await useCase();

      expect(status, isNull);
      verify(() => mockAuthRepo.getNotificationsEnabled()).called(1);
      verifyNever(() => mockFcmService.requestPermission());
    });

    test('session guard: should return null on subsequent calls in the same session',
        () async {
      final mockSettings = MockNotificationSettings();
      when(() => mockSettings.authorizationStatus)
          .thenReturn(AuthorizationStatus.authorized);
      when(() => mockAuthRepo.getNotificationsEnabled())
          .thenAnswer((_) async => true);
      when(() => mockFcmService.requestPermission())
          .thenAnswer((_) async => mockSettings);

      // First call executes normally
      final firstStatus = await useCase();
      expect(firstStatus, equals(AuthorizationStatus.authorized));
      verify(() => mockAuthRepo.getNotificationsEnabled()).called(1);
      verify(() => mockFcmService.requestPermission()).called(1);

      // Second call is guarded by session
      final secondStatus = await useCase();
      expect(secondStatus, isNull);
      // No additional calls to auth repo or FCM
      verifyNoMoreInteractions(mockAuthRepo);
      verifyNoMoreInteractions(mockFcmService);
    });

    test('forceCheck: true should bypass session guard', () async {
      final mockSettings = MockNotificationSettings();
      when(() => mockSettings.authorizationStatus)
          .thenReturn(AuthorizationStatus.authorized);
      when(() => mockAuthRepo.getNotificationsEnabled())
          .thenAnswer((_) async => true);
      when(() => mockFcmService.requestPermission())
          .thenAnswer((_) async => mockSettings);

      // First call executes
      await useCase();

      // Second call with forceCheck = true should execute despite session guard
      final secondStatus = await useCase(forceCheck: true);
      expect(secondStatus, equals(AuthorizationStatus.authorized));
      verify(() => mockAuthRepo.getNotificationsEnabled()).called(2);
      verify(() => mockFcmService.requestPermission()).called(2);
    });

    test('resetSession should clear the session guard', () async {
      final mockSettings = MockNotificationSettings();
      when(() => mockSettings.authorizationStatus)
          .thenReturn(AuthorizationStatus.authorized);
      when(() => mockAuthRepo.getNotificationsEnabled())
          .thenAnswer((_) async => true);
      when(() => mockFcmService.requestPermission())
          .thenAnswer((_) async => mockSettings);

      // First call
      await useCase();

      // Reset session
      SyncNotificationPermissionUseCase.resetSession();

      // Second call should run again
      final status = await useCase();
      expect(status, equals(AuthorizationStatus.authorized));
      verify(() => mockAuthRepo.getNotificationsEnabled()).called(2);
      verify(() => mockFcmService.requestPermission()).called(2);
    });
  });
}

import 'dart:async';

import 'package:flower_app/config/device/device_id_service_.dart';
import 'package:flower_app/config/notificaions/fcm.dart';
import 'package:flower_app/config/secure_storage/secure_storage.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/features/notifications/data/models/update_fcm_token.dart';
import 'package:flower_app/features/notifications/data/remote_data_source.dart';
import 'package:flower_app/features/notifications/data/repo_imp/repo_imp.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRemoteDataSource extends Mock
    implements NotificationRemoteDataSource {}

class MockFcmService extends Mock implements FcmService {}

class MockSecureStorage extends Mock implements SecureStorage {}

class MockDeviceIdService extends Mock implements DeviceIdService {}

class FakeUpdateFcmTokenRequest extends Fake implements UpdateFcmTokenRequest {}

void main() {
  late MockNotificationRemoteDataSource mockRemoteDataSource;
  late MockFcmService mockFcm;
  late MockSecureStorage mockSecureStorage;
  late MockDeviceIdService mockDeviceIdService;
  late StreamController<String> tokenRefreshController;
  late NotificationRepoImpl repo;

  setUpAll(() {
    registerFallbackValue(FakeUpdateFcmTokenRequest());
  });

  setUp(() {
    mockRemoteDataSource = MockNotificationRemoteDataSource();
    mockFcm = MockFcmService();
    mockSecureStorage = MockSecureStorage();
    mockDeviceIdService = MockDeviceIdService();
    tokenRefreshController = StreamController<String>.broadcast();

    when(() => mockDeviceIdService.getDeviceId())
        .thenAnswer((_) async => 'test_device_id_123');

    when(() => mockFcm.onTokenRefreshStream)
        .thenAnswer((_) => tokenRefreshController.stream);

    repo = NotificationRepoImpl(
      mockRemoteDataSource,
      mockFcm,
      mockSecureStorage,
      mockDeviceIdService,
    );
  });

  tearDown(() async {
    repo.dispose();
    await tokenRefreshController.close();
  });

  group('NotificationRepoImpl.updateFcmToken', () {
    const testToken = 'fcm_token_xyz';

    test('should call remoteDataSource with correct fcmToken and deviceId', () async {
      when(() => mockRemoteDataSource.updateFcmToken(any()))
          .thenAnswer((_) async {});

      await repo.updateFcmToken(fcmToken: testToken);

      verify(() => mockRemoteDataSource.updateFcmToken(
            any(
              that: isA<UpdateFcmTokenRequest>()
                  .having((r) => r.fcmToken, 'fcmToken', testToken)
                  .having((r) => r.deviceId, 'deviceId', 'test_device_id_123'),
            ),
          )).called(1);
    });

    test('should propagate error if remoteDataSource throws', () async {
      when(() => mockRemoteDataSource.updateFcmToken(any()))
          .thenThrow(Exception('Network error'));

      expect(
        () => repo.updateFcmToken(fcmToken: testToken),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('NotificationRepoImpl.syncFcmToken', () {
    const lastFcmTokenKey = 'last_fcm_token';
    const currentToken = 'current_fcm_token_123';
    const storedToken = 'stored_fcm_token_old';
    const userAuthToken = 'valid_auth_token_456';

    test('should return early if user is not logged in (auth token is null)', () async {
      when(() => mockSecureStorage.read(key: AppStrings.accessToken))
          .thenAnswer((_) async => null);

      await repo.syncFcmToken();

      verifyNever(() => mockFcm.getToken());
      verifyNever(() => mockRemoteDataSource.updateFcmToken(any()));
      verifyNever(() => mockSecureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ));
    });

    test('should return early if auth token is empty', () async {
      when(() => mockSecureStorage.read(key: AppStrings.accessToken))
          .thenAnswer((_) async => '');

      await repo.syncFcmToken();

      verifyNever(() => mockFcm.getToken());
      verifyNever(() => mockRemoteDataSource.updateFcmToken(any()));
    });

    test(
        'should upload token and save to secure storage when currentToken is different from storedToken',
        () async {
      when(() => mockSecureStorage.read(key: AppStrings.accessToken))
          .thenAnswer((_) async => userAuthToken);
      when(() => mockFcm.getToken()).thenAnswer((_) async => currentToken);
      when(() => mockSecureStorage.read(key: lastFcmTokenKey))
          .thenAnswer((_) async => storedToken);
      when(() => mockRemoteDataSource.updateFcmToken(any()))
          .thenAnswer((_) async {});
      when(() => mockSecureStorage.write(
            key: lastFcmTokenKey,
            value: currentToken,
          )).thenAnswer((_) async {});

      await repo.syncFcmToken();

      verify(() => mockRemoteDataSource.updateFcmToken(
            any(that: isA<UpdateFcmTokenRequest>().having((r) => r.fcmToken, 'fcmToken', currentToken)),
          )).called(1);
      verify(() => mockSecureStorage.write(key: lastFcmTokenKey, value: currentToken)).called(1);
    });

    test(
        'should not upload or save token when currentToken matches storedToken',
        () async {
      when(() => mockSecureStorage.read(key: AppStrings.accessToken))
          .thenAnswer((_) async => userAuthToken);
      when(() => mockFcm.getToken()).thenAnswer((_) async => currentToken);
      when(() => mockSecureStorage.read(key: lastFcmTokenKey))
          .thenAnswer((_) async => currentToken);

      await repo.syncFcmToken();

      verifyNever(() => mockRemoteDataSource.updateFcmToken(any()));
      verifyNever(() => mockSecureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ));
    });

    test('should not upload if currentToken is null', () async {
      when(() => mockSecureStorage.read(key: AppStrings.accessToken))
          .thenAnswer((_) async => userAuthToken);
      when(() => mockFcm.getToken()).thenAnswer((_) async => null);
      when(() => mockSecureStorage.read(key: lastFcmTokenKey))
          .thenAnswer((_) async => storedToken);

      await repo.syncFcmToken();

      verifyNever(() => mockRemoteDataSource.updateFcmToken(any()));
      verifyNever(() => mockSecureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ));
    });

    test(
        'should catch exception and not save token if upload fails during initial sync',
        () async {
      when(() => mockSecureStorage.read(key: AppStrings.accessToken))
          .thenAnswer((_) async => userAuthToken);
      when(() => mockFcm.getToken()).thenAnswer((_) async => currentToken);
      when(() => mockSecureStorage.read(key: lastFcmTokenKey))
          .thenAnswer((_) async => storedToken);
      when(() => mockRemoteDataSource.updateFcmToken(any()))
          .thenThrow(Exception('Server unreachable'));

      // Should complete without throwing uncaught exception
      await repo.syncFcmToken();

      verify(() => mockRemoteDataSource.updateFcmToken(any())).called(1);
      // write should NOT be called so next launch can retry
      verifyNever(() => mockSecureStorage.write(
            key: lastFcmTokenKey,
            value: any(named: 'value'),
          ));
    });

    test(
        'should upload and save token when new token is received from onTokenRefreshStream and user is logged in',
        () async {
      when(() => mockSecureStorage.read(key: AppStrings.accessToken))
          .thenAnswer((_) async => userAuthToken);
      when(() => mockFcm.getToken()).thenAnswer((_) async => currentToken);
      when(() => mockSecureStorage.read(key: lastFcmTokenKey))
          .thenAnswer((_) async => currentToken);
      when(() => mockRemoteDataSource.updateFcmToken(any()))
          .thenAnswer((_) async {});
      when(() => mockSecureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenAnswer((_) async {});

      await repo.syncFcmToken();

      // Emit new refreshed token on the stream
      const refreshedToken = 'new_refreshed_token_789';
      tokenRefreshController.add(refreshedToken);
      await pumpEventQueue();

      verify(() => mockRemoteDataSource.updateFcmToken(
            any(that: isA<UpdateFcmTokenRequest>().having((r) => r.fcmToken, 'fcmToken', refreshedToken)),
          )).called(1);
      verify(() => mockSecureStorage.write(key: lastFcmTokenKey, value: refreshedToken)).called(1);
    });

    test(
        'should ignore refreshed token if user has logged out before refresh event',
        () async {
      // Initially logged in
      when(() => mockSecureStorage.read(key: AppStrings.accessToken))
          .thenAnswer((_) async => userAuthToken);
      when(() => mockFcm.getToken()).thenAnswer((_) async => currentToken);
      when(() => mockSecureStorage.read(key: lastFcmTokenKey))
          .thenAnswer((_) async => currentToken);

      await repo.syncFcmToken();

      // User logs out (accessToken becomes null)
      when(() => mockSecureStorage.read(key: AppStrings.accessToken))
          .thenAnswer((_) async => null);

      tokenRefreshController.add('refreshed_while_logged_out');
      await pumpEventQueue();

      verifyNever(() => mockRemoteDataSource.updateFcmToken(any()));
      verifyNever(() => mockSecureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ));
    });
  });

  group('NotificationRepoImpl.dispose', () {
    test('cancels token refresh stream subscription', () async {
      when(() => mockSecureStorage.read(key: AppStrings.accessToken))
          .thenAnswer((_) async => 'auth_token');
      when(() => mockFcm.getToken()).thenAnswer((_) async => 'token');
      when(() => mockSecureStorage.read(key: 'last_fcm_token'))
          .thenAnswer((_) async => 'token');

      await repo.syncFcmToken();
      repo.dispose();

      // Emitting to the stream after dispose should not trigger any uploads
      tokenRefreshController.add('token_after_dispose');
      await pumpEventQueue();

      verifyNever(() => mockRemoteDataSource.updateFcmToken(any()));
    });
  });
}

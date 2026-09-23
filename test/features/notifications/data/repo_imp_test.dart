import 'dart:async';
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

class FakeUpdateFcmTokenRequest extends Fake
    implements UpdateFcmTokenRequest {}

void main() {
  late MockNotificationRemoteDataSource mockRemoteDataSource;
  late MockFcmService mockFcm;
  late MockSecureStorage mockSecureStorage;
  late NotificationRepoImpl repo;
  late StreamController<String> tokenRefreshController;

  const tAccessToken = 'test-access-token';
  const tLastFcmTokenKey = 'last_fcm_token';
  const tFcmToken = 'fcm-token-123';

  setUpAll(() {
    registerFallbackValue(FakeUpdateFcmTokenRequest());
  });

  setUp(() {
    mockRemoteDataSource = MockNotificationRemoteDataSource();
    mockFcm = MockFcmService();
    mockSecureStorage = MockSecureStorage();
    tokenRefreshController = StreamController<String>.broadcast();

    when(() => mockFcm.onTokenRefreshStream)
        .thenAnswer((_) => tokenRefreshController.stream);

    repo = NotificationRepoImpl(
      mockRemoteDataSource,
      mockFcm,
      mockSecureStorage,
    );
  });

  tearDown(() {
    repo.dispose();
    tokenRefreshController.close();
  });

  group('NotificationRepoImpl - updateFcmToken', () {
    test('calls remoteDataSource with mapped UpdateFcmTokenRequest', () async {
      when(() => mockRemoteDataSource.updateFcmToken(any()))
          .thenAnswer((_) async {});

      await repo.updateFcmToken(fcmToken: tFcmToken);

      final captured = verify(
        () => mockRemoteDataSource.updateFcmToken(captureAny()),
      ).captured;

      expect(captured.length, 1);
      final request = captured.first as UpdateFcmTokenRequest;
      expect(request.token, tFcmToken);
      expect(request.platform, anyOf('iOS', 'Android'));
    });

    test('propagates error when remoteDataSource throws', () async {
      when(() => mockRemoteDataSource.updateFcmToken(any()))
          .thenThrow(Exception('Server error'));

      expect(
        () => repo.updateFcmToken(fcmToken: tFcmToken),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('NotificationRepoImpl - syncFcmToken', () {
    test('returns early without syncing when user is logged out (no accessToken)', () async {
      when(() => mockSecureStorage.read(key: AppStrings.accessToken))
          .thenAnswer((_) async => null);

      await repo.syncFcmToken();

      verify(() => mockSecureStorage.read(key: AppStrings.accessToken)).called(1);
      verifyZeroInteractions(mockFcm);
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('syncs token and writes to storage when currentToken is new and user is logged in', () async {
      when(() => mockSecureStorage.read(key: AppStrings.accessToken))
          .thenAnswer((_) async => tAccessToken);
      when(() => mockFcm.getToken()).thenAnswer((_) async => tFcmToken);
      when(() => mockSecureStorage.read(key: tLastFcmTokenKey))
          .thenAnswer((_) async => null);
      when(() => mockRemoteDataSource.updateFcmToken(any()))
          .thenAnswer((_) async {});
      when(() => mockSecureStorage.write(key: tLastFcmTokenKey, value: tFcmToken))
          .thenAnswer((_) async {});

      await repo.syncFcmToken();

      verify(() => mockRemoteDataSource.updateFcmToken(any())).called(1);
      verify(() => mockSecureStorage.write(key: tLastFcmTokenKey, value: tFcmToken))
          .called(1);
    });

    test('does NOT upload when currentToken matches storedToken', () async {
      when(() => mockSecureStorage.read(key: AppStrings.accessToken))
          .thenAnswer((_) async => tAccessToken);
      when(() => mockFcm.getToken()).thenAnswer((_) async => tFcmToken);
      when(() => mockSecureStorage.read(key: tLastFcmTokenKey))
          .thenAnswer((_) async => tFcmToken);

      await repo.syncFcmToken();

      verifyNever(() => mockRemoteDataSource.updateFcmToken(any()));
      verifyNever(() => mockSecureStorage.write(
            key: tLastFcmTokenKey,
            value: any(named: 'value'),
          ));
    });

    test('syncs token when onTokenRefreshStream emits and user is still logged in', () async {
      when(() => mockSecureStorage.read(key: AppStrings.accessToken))
          .thenAnswer((_) async => tAccessToken);
      when(() => mockFcm.getToken()).thenAnswer((_) async => tFcmToken);
      when(() => mockSecureStorage.read(key: tLastFcmTokenKey))
          .thenAnswer((_) async => tFcmToken);

      const tRefreshedToken = 'refreshed-fcm-token-456';
      when(() => mockRemoteDataSource.updateFcmToken(any()))
          .thenAnswer((_) async {});
      when(() => mockSecureStorage.write(key: tLastFcmTokenKey, value: tRefreshedToken))
          .thenAnswer((_) async {});

      await repo.syncFcmToken();

      // Emit new token via stream
      tokenRefreshController.add(tRefreshedToken);
      await pumpEventQueue();

      verify(() => mockRemoteDataSource.updateFcmToken(any())).called(1);
      verify(() => mockSecureStorage.write(key: tLastFcmTokenKey, value: tRefreshedToken))
          .called(1);
    });
  });
}

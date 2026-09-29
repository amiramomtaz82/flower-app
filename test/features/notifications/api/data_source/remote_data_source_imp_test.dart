import 'package:flower_app/features/notifications/api/client/notification_api_client.dart';
import 'package:flower_app/features/notifications/api/data_source/remote_data_source_imp.dart';
import 'package:flower_app/features/notifications/data/models/update_fcm_token.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationApiClient extends Mock implements NotificationApiClient {}

class FakeUpdateFcmTokenRequest extends Fake implements UpdateFcmTokenRequest {}

void main() {
  late MockNotificationApiClient mockApiClient;
  late NotificationRemoteDataSourceImpl remoteDataSource;

  setUpAll(() {
    registerFallbackValue(FakeUpdateFcmTokenRequest());
  });

  setUp(() {
    mockApiClient = MockNotificationApiClient();
    remoteDataSource = NotificationRemoteDataSourceImpl(mockApiClient);
  });

  group('NotificationRemoteDataSourceImpl', () {
    const request = UpdateFcmTokenRequest(
      deviceId: 'test_device_123',
      fcmToken: 'test_token_123',
    );

    test('should call updateFcmToken on NotificationApiClient with the given request', () async {
      when(() => mockApiClient.updateFcmToken(any()))
          .thenAnswer((_) async {});

      await remoteDataSource.updateFcmToken(request);

      verify(() => mockApiClient.updateFcmToken(request)).called(1);
      verifyNoMoreInteractions(mockApiClient);
    });

    test('should propagate error when NotificationApiClient throws an exception', () async {
      when(() => mockApiClient.updateFcmToken(any()))
          .thenThrow(Exception('Server error'));

      expect(() => remoteDataSource.updateFcmToken(request), throwsA(isA<Exception>()));
      verify(() => mockApiClient.updateFcmToken(request)).called(1);
    });
  });
}

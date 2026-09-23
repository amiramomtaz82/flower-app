import 'package:flower_app/features/notifications/api/client/notification_api_client.dart';
import 'package:flower_app/features/notifications/api/data_source/remote_data_source_imp.dart';
import 'package:flower_app/features/notifications/data/models/update_fcm_token.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationApiClient extends Mock
    implements NotificationApiClient {}

class FakeUpdateFcmTokenRequest extends Fake
    implements UpdateFcmTokenRequest {}

void main() {
  late MockNotificationApiClient mockApiClient;
  late NotificationRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(FakeUpdateFcmTokenRequest());
  });

  setUp(() {
    mockApiClient = MockNotificationApiClient();
    dataSource = NotificationRemoteDataSourceImpl(mockApiClient);
  });

  group('NotificationRemoteDataSourceImpl', () {
    const tRequest = UpdateFcmTokenRequest(
      token: 'fcm-token-abc',
      platform: 'Android',
    );

    test('updateFcmToken calls apiClient.updateFcmToken with correct request', () async {
      when(() => mockApiClient.updateFcmToken(any()))
          .thenAnswer((_) async {});

      await dataSource.updateFcmToken(tRequest);

      verify(() => mockApiClient.updateFcmToken(tRequest)).called(1);
    });

    test('updateFcmToken propagates exception when apiClient throws', () async {
      when(() => mockApiClient.updateFcmToken(any()))
          .thenThrow(Exception('API error'));

      expect(
        () => dataSource.updateFcmToken(tRequest),
        throwsA(isA<Exception>()),
      );
    });
  });
}

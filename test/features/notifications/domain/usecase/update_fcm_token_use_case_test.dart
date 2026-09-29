import 'package:flower_app/features/notifications/domain/repo/repo.dart';
import 'package:flower_app/features/notifications/domain/usecase/update_fcm_token_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRepo extends Mock implements NotificationRepo {}

void main() {
  late MockNotificationRepo mockNotificationRepo;
  late UpdateFcmTokenUseCase useCase;

  setUp(() {
    mockNotificationRepo = MockNotificationRepo();
    useCase = UpdateFcmTokenUseCase(mockNotificationRepo);
  });

  group('UpdateFcmTokenUseCase', () {
    const testToken = 'fcm_token_sample_123';

    test('should call updateFcmToken on NotificationRepo with correct token', () async {
      when(() => mockNotificationRepo.updateFcmToken(fcmToken: any(named: 'fcmToken')))
          .thenAnswer((_) async {});

      await useCase(fcmToken: testToken);

      verify(() => mockNotificationRepo.updateFcmToken(fcmToken: testToken)).called(1);
      verifyNoMoreInteractions(mockNotificationRepo);
    });

    test('should propagate error if NotificationRepo throws', () async {
      when(() => mockNotificationRepo.updateFcmToken(fcmToken: any(named: 'fcmToken')))
          .thenThrow(Exception('Update token failed'));

      expect(() => useCase(fcmToken: testToken), throwsA(isA<Exception>()));
      verify(() => mockNotificationRepo.updateFcmToken(fcmToken: testToken)).called(1);
    });
  });
}

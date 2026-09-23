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
    const tFcmToken = 'fcm-token-test';

    test('calls notificationRepo.updateFcmToken with correct argument', () async {
      when(
        () => mockNotificationRepo.updateFcmToken(
          fcmToken: tFcmToken,
        ),
      ).thenAnswer((_) async {});

      await useCase(fcmToken: tFcmToken);

      verify(
        () => mockNotificationRepo.updateFcmToken(
          fcmToken: tFcmToken,
        ),
      ).called(1);
    });

    test('propagates exception when notificationRepo throws', () async {
      when(
        () => mockNotificationRepo.updateFcmToken(
          fcmToken: tFcmToken,
        ),
      ).thenThrow(Exception('Failed to update token'));

      expect(
        () => useCase(fcmToken: tFcmToken),
        throwsA(isA<Exception>()),
      );
    });
  });
}

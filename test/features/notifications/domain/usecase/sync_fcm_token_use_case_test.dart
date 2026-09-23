import 'package:flower_app/features/notifications/domain/repo/repo.dart';
import 'package:flower_app/features/notifications/domain/usecase/sync_fcm_token_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRepo extends Mock implements NotificationRepo {}

void main() {
  late MockNotificationRepo mockNotificationRepo;
  late SyncFcmTokenUseCase useCase;

  setUp(() {
    mockNotificationRepo = MockNotificationRepo();
    useCase = SyncFcmTokenUseCase(mockNotificationRepo);
  });

  group('SyncFcmTokenUseCase', () {
    test('calls notificationRepo.syncFcmToken', () async {
      when(() => mockNotificationRepo.syncFcmToken())
          .thenAnswer((_) async {});

      await useCase();

      verify(() => mockNotificationRepo.syncFcmToken()).called(1);
    });

    test('propagates error when notificationRepo throws', () async {
      when(() => mockNotificationRepo.syncFcmToken())
          .thenThrow(Exception('Sync error'));

      expect(() => useCase(), throwsA(isA<Exception>()));
    });
  });
}

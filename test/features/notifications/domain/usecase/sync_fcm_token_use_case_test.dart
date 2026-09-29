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
    test('should call syncFcmToken on NotificationRepo', () async {
      when(() => mockNotificationRepo.syncFcmToken())
          .thenAnswer((_) async {});

      await useCase();

      verify(() => mockNotificationRepo.syncFcmToken()).called(1);
      verifyNoMoreInteractions(mockNotificationRepo);
    });

    test('should propagate error if NotificationRepo throws', () async {
      when(() => mockNotificationRepo.syncFcmToken())
          .thenThrow(Exception('Sync failed'));

      expect(() => useCase(), throwsA(isA<Exception>()));
      verify(() => mockNotificationRepo.syncFcmToken()).called(1);
    });
  });
}

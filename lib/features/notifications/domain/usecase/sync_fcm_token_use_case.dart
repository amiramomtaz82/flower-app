import 'package:injectable/injectable.dart';
import '../repo/repo.dart';

@injectable
class SyncFcmTokenUseCase {
  final NotificationRepo _notificationRepo;

  SyncFcmTokenUseCase(this._notificationRepo);

  Future<void> call() => _notificationRepo.syncFcmToken();
}
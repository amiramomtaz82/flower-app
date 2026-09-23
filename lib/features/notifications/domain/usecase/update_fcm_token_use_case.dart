import 'package:injectable/injectable.dart';
import '../repo/repo.dart';

@injectable
class UpdateFcmTokenUseCase {
  final NotificationRepo _notificationRepo;

  UpdateFcmTokenUseCase(this._notificationRepo);

  Future<void> call({required String fcmToken}) {
    return _notificationRepo.updateFcmToken(fcmToken: fcmToken);
  }
}
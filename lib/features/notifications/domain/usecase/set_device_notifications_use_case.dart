import 'package:flower_app/features/notifications/domain/usecase/sync_notification_permission_use_case.dart';
import 'package:injectable/injectable.dart';

import '../repo/repo.dart';

@injectable
class SetDeviceNotificationsUseCase {
  final NotificationRepo _repo;
  final SyncNotificationPermissionUseCase _syncPermissionUseCase;

  SetDeviceNotificationsUseCase(this._repo, this._syncPermissionUseCase);

  Future<void> call({required bool enabled}) async {
    await _repo.setDeviceNotifications(enabled: enabled);
    // If the user toggled ON, prompt for OS notification permission if not yet granted
    if (enabled) {
      await _syncPermissionUseCase(forceCheck: true);
    }
  }
}
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';

import '../../../../config/notificaions/fcm.dart';
import '../../../auth/domain/repo/auth_repo.dart';

@injectable
class SyncNotificationPermissionUseCase {
  final AuthRepo _authRepo;
  final FcmService _fcm;

  // In-memory session guard: survives tab switching, resets when app process is closed
  static bool _hasCheckedThisSession = false;

  SyncNotificationPermissionUseCase(
      this._authRepo,
      this._fcm,
      );

  /// Allows resetting the flag (useful for testing or logout)
  static void resetSession() {
    _hasCheckedThisSession = false;
  }

  /// Checks and prompts for OS permission if the user has app notifications enabled.
  /// Returns the current AuthorizationStatus (or null if skipped due to session guard or preference).
  Future<AuthorizationStatus?> call({bool forceCheck = false}) async {
    // 1. Guard: Only run once per app session (unless explicitly forced from Profile toggle)
    if (!forceCheck && _hasCheckedThisSession) {
      return null;
    }
    _hasCheckedThisSession = true;

    // 2. Check if user has app-level notifications turned ON
    final isAppLevelEnabled = await _authRepo.getNotificationsEnabled();
    if (!isAppLevelEnabled) {
      return null;
    }

    // 3. Request OS-level permission via FCM
    final settings = await _fcm.requestPermission();

    // NOTE: We do NOT call `_authRepo.saveNotificationsEnabled(isGranted)` here!
    // The user's preference (`notifications_enabled`) remains `true` even if
    // the OS permission is denied.

    return settings.authorizationStatus;
  }
}
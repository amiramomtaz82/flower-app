import 'dart:async';
import 'package:injectable/injectable.dart';
import '../../features/auth/data/data_source/local/auth_local_data_source.dart';
import '../../features/notifications/domain/repo.dart';
import '../device/device_id_service_.dart';
import '../secure_storage/secure_storage.dart';
import 'fcm.dart';

@lazySingleton
class FcmTokenSyncService {
  final Fcm _fcm;
  final DeviceIdService _deviceIdService;
  final AuthLocalDataSource _authLocalDataSource;
  final SecureStorage _secureStorage;
  final NotificationRepo _notificationRepo; // Inject repository

  StreamSubscription<String>? _refreshSubscription;
  static const String _lastFcmTokenKey = 'last_fcm_token';

  FcmTokenSyncService(
    this._fcm,
    this._deviceIdService,
    this._authLocalDataSource,
    this._secureStorage,
    this._notificationRepo,
  );

  Future<void> initFcmTokenSync() async {
    final currentToken = await _fcm.getToken();
    final storedToken = await _secureStorage.read(key: _lastFcmTokenKey);

    if (currentToken != null && currentToken != storedToken) {
      await _syncToken(currentToken);
    }

    await _refreshSubscription?.cancel();
    _refreshSubscription = _fcm.onTokenRefreshStream.listen((newToken) async {
      await _syncToken(newToken);
    });
  }

  Future<void> _syncToken(String token) async {
    final user = await _authLocalDataSource.getUser();
    final deviceId = await _deviceIdService.getDeviceId();

    if (user != null) {
      try {
        await _notificationRepo.updateFcmToken(
          deviceId: deviceId,
          userId: user.id,
          fcmToken: token,
        );
        await _secureStorage.write(key: _lastFcmTokenKey, value: token);
      } catch (_) {
        // Leave _lastFcmTokenKey unchanged so the next app start retries the sync
      }
    } else {
      await _secureStorage.write(key: _lastFcmTokenKey, value: token);
    }
  }

  void dispose() {
    _refreshSubscription?.cancel();
  }
}

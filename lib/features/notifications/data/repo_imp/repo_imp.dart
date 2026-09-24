import 'dart:async';
import 'dart:io';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:injectable/injectable.dart';

import '../../../../../config/notificaions/fcm.dart';
import '../../../../../config/secure_storage/secure_storage.dart';
import '../../domain/repo/repo.dart';
import '../models/update_fcm_token.dart';

import '../remote_data_source.dart';

@LazySingleton(as: NotificationRepo)
class NotificationRepoImpl implements NotificationRepo {
  final NotificationRemoteDataSource _remoteDataSource;
  final FcmService _fcm;
  final SecureStorage _secureStorage;

  StreamSubscription<String>? _refreshSubscription;
  static const String _lastFcmTokenKey = 'last_fcm_token';

  NotificationRepoImpl(
      this._remoteDataSource,
      this._fcm,
      this._secureStorage,
      );

  @override
  Future<void> syncFcmToken() async {
    // Guard clause: Only sync when the user is logged in
    final authToken = await _secureStorage.read(key: AppStrings.accessToken);
    if (authToken == null || authToken.isEmpty) {
      return;
    }

    final currentToken = await _fcm.getToken();
    final storedToken = await _secureStorage.read(key: _lastFcmTokenKey);

    if (currentToken != null && currentToken != storedToken) {
      await _uploadAndSaveToken(currentToken);
    }

    await _refreshSubscription?.cancel();
    _refreshSubscription = _fcm.onTokenRefreshStream.listen((newToken) async {
      final token = await _secureStorage.read(key: AppStrings.accessToken);
      if (token != null && token.isNotEmpty) {
        await _uploadAndSaveToken(newToken);
      }
    });
  }

  Future<void> _uploadAndSaveToken(String token) async {
    try {
      await updateFcmToken(fcmToken: token);
      await _secureStorage.write(key: _lastFcmTokenKey, value: token);
    } catch (_) {
      // Keeps last token unwritten so next launch retries
    }
  }

  @override
  Future<void> updateFcmToken({required String fcmToken}) async {
    final platform = Platform.isIOS ? 'iOS' : 'Android';
    final request = UpdateFcmTokenRequest(
      token: fcmToken,
      platform: platform,
    );
    await _remoteDataSource.updateFcmToken(request);
  }

  @override
  void dispose() {
    _refreshSubscription?.cancel();
  }
}
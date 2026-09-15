import 'package:flower_app/features/notifications/data/remote_data_source.dart';
import 'package:injectable/injectable.dart';

import '../domain/repo.dart';

import 'models/update_fecm_token.dart';

@LazySingleton(as: NotificationRepo)
class NotificationRepoImpl implements NotificationRepo {
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepoImpl(this._remoteDataSource);

  @override
  Future<void> updateFcmToken({
    required String deviceId,
    required String userId,
    required String fcmToken,
  }) async {
    final request = UpdateFcmTokenRequest(
      deviceId: deviceId,
      userId: userId,
      fcmToken: fcmToken,
    );
    await _remoteDataSource.updateFcmToken(request);
  }
}
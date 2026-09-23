import 'models/update_fcm_token.dart';

abstract  interface class NotificationRemoteDataSource {
  Future<void> updateFcmToken(UpdateFcmTokenRequest request);
}
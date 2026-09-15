import 'models/update_fecm_token.dart';

abstract class NotificationRemoteDataSource {
  Future<void> updateFcmToken(UpdateFcmTokenRequest request);
}
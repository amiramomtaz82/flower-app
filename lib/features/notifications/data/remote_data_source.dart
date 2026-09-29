import 'models/set_device_notification_request.dart';
import 'models/update_fcm_token.dart';

abstract  interface class NotificationRemoteDataSource {
  Future<void> updateFcmToken(UpdateFcmTokenRequest request);
  Future<void> setDeviceNotifications(SetDeviceNotificationsRequest request);
}
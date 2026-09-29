import 'package:flower_app/features/notifications/data/models/set_device_notification_request.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/update_fcm_token.dart';
import '../../data/remote_data_source.dart';
import '../client/notification_api_client.dart';

@Injectable(as: NotificationRemoteDataSource)
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final NotificationApiClient _apiClient;

  NotificationRemoteDataSourceImpl(this._apiClient);

  @override
  Future<void> updateFcmToken(UpdateFcmTokenRequest request) async {
    await _apiClient.updateFcmToken(request);
  }

  @override
  Future<void> setDeviceNotifications(
      SetDeviceNotificationsRequest request) async {
    await _apiClient.setDeviceNotifications(request);
  }
}
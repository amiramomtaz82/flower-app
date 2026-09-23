import 'package:injectable/injectable.dart';

import '../../data/models/update_fcm_token.dart';
import '../../data/remote_data_source.dart';
import '../client/notification_api_client.dart';

@LazySingleton(as: NotificationRemoteDataSource)
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final NotificationApiClient _apiClient; // 👈 Inject ApiClient instead of raw Dio

  NotificationRemoteDataSourceImpl(this._apiClient);

  @override
  Future<void> updateFcmToken(UpdateFcmTokenRequest request) async {
    await _apiClient.updateFcmToken(request);
  }
}
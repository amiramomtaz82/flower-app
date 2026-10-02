

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/app_constants/endpoints.dart';
import '../../data/models/set_device_notification_request.dart';
import '../../data/models/update_fcm_token.dart';


part 'notification_api_client.g.dart';

@RestApi()
@lazySingleton
abstract class NotificationApiClient {
  @factoryMethod
  factory NotificationApiClient(Dio dio) = _NotificationApiClient;

  @POST(Endpoints.update_fcm_token)
  Future<void> updateFcmToken(
      @Body() UpdateFcmTokenRequest request,
      );
  @PUT(Endpoints.deviceNotifications)
  Future<void> setDeviceNotifications(
      @Body() SetDeviceNotificationsRequest request,
      );
}
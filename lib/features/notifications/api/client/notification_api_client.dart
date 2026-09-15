

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import '../../data/models/update_fecm_token.dart';


part 'notification_api_client.g.dart';

@RestApi()
@lazySingleton
abstract class NotificationApiClient {
  @factoryMethod
  factory NotificationApiClient(Dio dio) = _NotificationApiClient;

  @PUT('/devices/fcm-token') // Verify the exact path in your Postman collection
  Future<void> updateFcmToken(
      @Body() UpdateFcmTokenRequest request,
      );
}
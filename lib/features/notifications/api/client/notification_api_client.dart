

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/app_constants/endpoints.dart';
import '../../data/models/update_fcm_token.dart';


part 'notification_api_client.g.dart';

@RestApi()
@lazySingleton
abstract class NotificationApiClient {
  @factoryMethod
  factory NotificationApiClient(Dio dio) = _NotificationApiClient;

  @POST(Endpoints.registerDevice)
  Future<void> updateFcmToken(
      @Body() UpdateFcmTokenRequest request,
      );
}
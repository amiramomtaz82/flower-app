import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:flower_app/core/app_constants/endpoints.dart';
import 'package:flower_app/features/profile/data/models/profile_response_model.dart';
import 'package:injectable/injectable.dart';
part 'profile_api_client.g.dart';

@singleton
@RestApi()
abstract class ProfileApiClient {
  @factoryMethod
  factory ProfileApiClient(Dio dio) = _ProfileApiClient;

  @GET(Endpoints.profile)
  Future<ProfileResponseModel> getProfile();
}

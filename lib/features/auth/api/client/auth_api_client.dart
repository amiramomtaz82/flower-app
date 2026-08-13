import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../data/models/LoginRequest.dart';
import '../../data/models/LoginResponse.dart';
part 'auth_api_client.g.dart';

@singleton
@RestApi()
abstract class AuthApiClient {
  @factoryMethod
  factory AuthApiClient(Dio dio) = _AuthApiClient;

  @POST('/auth/login')
  Future<LoginResponse> login(
      @Body() LoginRequest request,
      );
}

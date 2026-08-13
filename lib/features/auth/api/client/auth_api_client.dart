import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
part 'auth_api_client.g.dart';

@singleton
@RestApi()
abstract class AuthApiClient {
  @factoryMethod
  factory AuthApiClient(Dio dio) = _AuthApiClient;

  // TODO: implement login

  // TODO: implement register

  // TODO: implement forgetPassword

  // TODO: implement resetPassword
}

import 'package:dio/dio.dart';
import 'package:flower_app/features/auth/data/models/register_request.dart';
import 'package:flower_app/features/auth/data/models/register_response.dart';
import 'package:flower_app/core/app_constants/endpoints.dart';
import 'package:flower_app/core/app_constants/endpoints.dart';
import 'package:flower_app/features/auth/data/models/forgot_password_request_model.dart';
import 'package:flower_app/features/auth/data/models/message_response_model.dart';
import 'package:flower_app/features/auth/data/models/reset_password_request_model.dart';
import 'package:flower_app/features/auth/data/models/verify_otp_request_model.dart';
import 'package:flower_app/features/auth/data/models/verify_otp_response_model.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';


import '../../data/models/login_request.dart';
import '../../data/models/login_response.dart';
part 'auth_api_client.g.dart';

@singleton
@RestApi()
abstract class AuthApiClient {
  @factoryMethod
  factory AuthApiClient(Dio dio) = _AuthApiClient;

  @POST(Endpoints.loginEndPoint)
  Future<LoginResponse> login(
      @Body() LoginRequest request,
      );
  // TODO: implement login

  @POST('/auth/register')
  Future<AuthResponse> register(
    @Body() SignUpRequest request,
    @Header('Accept-Language') String language,
  );

  @POST(Endpoints.forgetPassword)
  Future<MessageResponseModel> forgetPassword(
    @Body() ForgotPasswordRequestModel body,
  );

  @POST(Endpoints.verifyOtp)
  Future<VerifyOtpResponseModel> verifyOtp(@Body() VerifyOtpRequestModel body);

  @POST(Endpoints.resetPassword)
  Future<MessageResponseModel> resetPassword(
    @Body() ResetPasswordRequestModel body,
  );
}

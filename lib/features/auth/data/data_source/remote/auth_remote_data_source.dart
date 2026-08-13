import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/api/client/auth_api_client.dart';
import 'package:flower_app/features/auth/data/models/login_request.dart';
import 'package:flower_app/features/auth/data/models/login_response.dart';

abstract interface class AuthRemoteDataSource {
  AuthApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);


  Future<BaseResponse<LoginResponse>> login(LoginRequest request);


}
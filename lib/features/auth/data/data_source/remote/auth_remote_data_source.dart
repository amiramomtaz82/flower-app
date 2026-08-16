import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/api/client/auth_api_client.dart';
import 'package:flower_app/features/auth/data/models/login_request.dart';
import 'package:flower_app/features/auth/data/models/login_response.dart';

import '../../models/register_request.dart';
import '../../models/register_response.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthResponse> signUp(SignUpRequest request);

  // TODO: implement login

  Future<BaseResponse<LoginResponse>> login(LoginRequest request);


}
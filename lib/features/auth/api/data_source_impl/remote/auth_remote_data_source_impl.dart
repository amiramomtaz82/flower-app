import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/api/client/auth_api_client.dart';
import 'package:flower_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:flower_app/features/auth/data/models/login_request.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/login_response.dart';

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthApiClient _authApiClient;

  AuthRemoteDataSourceImpl(this._authApiClient);

  bool useDummyLogin = false;

  @override
  Future<BaseResponse<LoginResponse>> login(LoginRequest request) async {
    if (useDummyLogin) {
      await Future.delayed(const Duration(seconds: 2));

      if (request.email == "customer@example.com" &&
          request.password == "Password123") {
        return SuccessResponse(
          LoginResponse(
            accessToken: "dummy_access_token",
            refreshToken: "dummy_refresh_token",
            expiresIn: 900,
            role: "Customer",
            user: User(
              id: "123",
              email: request.email,
              fullName: "Ahmed Hassan",
              role: "Customer",
              isActive: true,
            ),
          ),
        );
      }

      return ErrorResponse(errMessage: "Invalid email or password");
    }

    // Real API
    try {
      final response = await _authApiClient.login(request);

      return SuccessResponse<LoginResponse>(response);
    } on Exception catch (e) {
      return ErrorResponse<LoginResponse>(error: e);
    }
  }
}

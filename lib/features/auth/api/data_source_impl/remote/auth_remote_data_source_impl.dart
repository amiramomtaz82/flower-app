import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/api/client/auth_api_client.dart';
import 'package:flower_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:flower_app/features/auth/data/models/forgot_password_request_model.dart';
import 'package:flower_app/features/auth/data/models/login_request.dart';
import 'package:flower_app/features/auth/data/models/message_response_model.dart';
import 'package:flower_app/features/auth/data/models/register_request.dart';
import 'package:flower_app/features/auth/data/models/register_response.dart';
import 'package:flower_app/features/auth/data/models/reset_password_request_model.dart';
import 'package:flower_app/features/auth/data/models/verify_otp_request_model.dart';
import 'package:flower_app/features/auth/data/models/verify_otp_response_model.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/login_response.dart';

@Injectable(as: AuthRemoteDataSource)
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


  @override
  Future<AuthResponse> signUp(SignUpRequest request) {
    return _authApiClient.register(request);
  }

  @override
  Future<MessageResponseModel> forgetPassword({required String email}) async {
    final response = await _authApiClient.forgetPassword(
      ForgotPasswordRequestModel(email: email),
    );
    return response;
  }

  @override
  Future<VerifyOtpResponseData> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    final response = await _authApiClient.verifyOtp(
      VerifyOtpRequestModel(email: email, otpCode: otpCode),
    );
    return response.data;
  }

  @override
  Future<MessageResponseModel> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final requestModel = ResetPasswordRequestModel(
      resetToken: resetToken,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );
    final response = await _authApiClient.resetPassword(requestModel);
    return response;
  }
}

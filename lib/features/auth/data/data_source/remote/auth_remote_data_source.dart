import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/data/models/login_request.dart';
import 'package:flower_app/features/auth/data/models/login_response.dart';
import 'package:flower_app/features/auth/data/models/message_response_model.dart';
import 'package:flower_app/features/auth/data/models/verify_otp_response_model.dart';

import '../../models/register_request.dart';
import '../../models/register_response.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthResponse> signUp(SignUpRequest request);

  // TODO: implement login

  Future<BaseResponse<LoginResponse>> login(LoginRequest request);

  Future<MessageResponseModel> forgetPassword({required String email});

  Future<VerifyOtpResponseData> verifyOtp({
    required String email,
    required String otpCode,
  });

  Future<MessageResponseModel> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmNewPassword,
  });
}

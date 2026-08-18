import 'package:flower_app/features/auth/data/models/message_response_model.dart';
import 'package:flower_app/features/auth/data/models/verify_otp_response_model.dart';

abstract interface class AuthRemoteDataSource {
  // TODO: implement login

  // TODO: implement register

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

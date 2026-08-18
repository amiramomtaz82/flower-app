import 'package:flower_app/features/auth/api/client/auth_api_client.dart';
import 'package:flower_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:flower_app/features/auth/data/models/forgot_password_request_model.dart';
import 'package:flower_app/features/auth/data/models/message_response_model.dart';
import 'package:flower_app/features/auth/data/models/reset_password_request_model.dart';
import 'package:flower_app/features/auth/data/models/verify_otp_request_model.dart';
import 'package:flower_app/features/auth/data/models/verify_otp_response_model.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthApiClient _authApiClient;
  AuthRemoteDataSourceImpl(this._authApiClient);

  // TODO: implement login

  // TODO: implement register

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

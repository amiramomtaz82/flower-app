import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:flower_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:flower_app/features/auth/data/models/login_request.dart';
import 'package:flower_app/features/auth/data/models/login_response.dart';
import 'package:flower_app/features/auth/domain/entities/login_entity.dart';
import 'package:flower_app/features/auth/data/models/register_request.dart';
import 'package:flower_app/features/auth/domain/entities/auth_entity.dart';
import 'package:flower_app/features/auth/domain/entities/auth_message_entity.dart';
import 'package:flower_app/features/auth/domain/entities/reset_token_entity.dart';
import 'package:flower_app/features/auth/domain/repo/auth_repo.dart';
import 'package:injectable/injectable.dart';

import '../../../../config/device/device_id_service.dart';
import '../../../../config/notificaions/fcm.dart';

@Injectable(as: AuthRepo)
class AuthRepoImpl implements AuthRepo {
  final AuthRemoteDataSource _authRemoteDataSource;
  final AuthLocalDataSource _authLocalDataSource;
  final DeviceIdService _deviceIdService;
  final Fcm _fcm;

  AuthRepoImpl(
      this._authRemoteDataSource,
      this._authLocalDataSource,
      this._deviceIdService,
      this._fcm,
      );

  @override
  Future<BaseResponse<LoginEntity>> login({
    required String email,
    required String password,
  }) async {
    final deviceId = await _deviceIdService.getDeviceId();
    final fcmToken = await _fcm.getToken();

    final request = LoginRequest(
      email: email,
      password: password,
      deviceId: deviceId,
      fcmToken: fcmToken,
    );


    final BaseResponse<LoginResponse> response =
    await _authRemoteDataSource.login(request);



    switch (response) {
      case SuccessResponse<LoginResponse>():
        final loginResponse = response.data;

        if (loginResponse.accessToken != null) {
          await _authLocalDataSource.saveToken(
            loginResponse.accessToken!,
          );
        }

        if (loginResponse.refreshToken != null) {
          await _authLocalDataSource.saveRefreshToken(
            loginResponse.refreshToken!,
          );
        }


        if (loginResponse.user != null) {
          await _authLocalDataSource.saveUser(
            loginResponse.user!,
          );
        }

        final loginEntity = loginResponse.toEntity();

        return SuccessResponse<LoginEntity>(
          loginEntity,
        );

      case ErrorResponse<LoginResponse>():
        return ErrorResponse<LoginEntity>(
          errMessage: response.errMessage,
        );
    }
  }
  @override
  Future<BaseResponse<ResetToken>> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      final response = await _authRemoteDataSource.verifyOtp(
        email: email,
        otpCode: otpCode,
      );
      return SuccessResponse(response.toEntity());
    } on Exception catch (e) {
      return ErrorResponse(error: e);
    }
  }

  @override
  Future<BaseResponse<AuthMessageEntity>> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final response = await _authRemoteDataSource.resetPassword(
        resetToken: resetToken,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );
      // clear auth data when reset password success to avoid user relogin
      await _authLocalDataSource.clearAuthData();
      return SuccessResponse(response.toEntity());
    } on Exception catch (e) {
      return ErrorResponse(error: e);
    }
  }

        @override
        Future<BaseResponse<RegisterEntity>> signUp(SignUpRequest request) async {
          try {
            await _authRemoteDataSource.signUp(request);
            return SuccessResponse(
              RegisterEntity(
                firstName: request.firstName,
                lastName: request.lastName,
                email: request.email,
                phoneNumber: request.phoneNumber,
                gender: request.gender,
                password: request.password,
                confirmPassword: request.confirmPassword,
              ),
            );
          } catch (e) {
            return ErrorResponse(error: e);
          }
        }
        @override
        Future<BaseResponse<AuthMessageEntity>> forgetPassword({
          required String email,
        }) async {
          try {
            final response = await _authRemoteDataSource.forgetPassword(email: email);
            return SuccessResponse(response.toEntity());
          } on Exception catch (e) {
            return ErrorResponse(error: e);
          }
        }
}



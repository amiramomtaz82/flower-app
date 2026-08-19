import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/config/error/error_handler.dart';
import 'package:flower_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:flower_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:flower_app/features/auth/data/models/login_request.dart';
import 'package:flower_app/features/auth/data/models/login_response.dart';
import 'package:flower_app/features/auth/domain/entities/login_entity.dart';
import 'package:flower_app/features/auth/data/models/register_request.dart';
import 'package:flower_app/features/auth/domain/core/result.dart';
import 'package:flower_app/features/auth/domain/entities/auth_entity.dart';
import 'package:flower_app/features/auth/domain/entities/register_params.dart';
import 'package:flower_app/features/auth/domain/repo/auth_repo.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: AuthRepo)
import '../../../../config/device/device_id_service_.dart';

import '../../../../config/notificaions/fcm.dart';

@LazySingleton(as: AuthRepo)
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

  AuthRepoImpl(this._authRemoteDataSource, this._authLocalDataSource,
  this._deviceIdService,this._fcm);

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
  Future<Result<RegisterEntity>> signUp(RegisterParams params) async {
    try {
      final request = SignUpRequest(
        firstName: params.firstName,
        lastName: params.lastName,
        email: params.email,
        password: params.password,
        confirmPassword: params.confirmPassword,
        phoneNumber: params.phoneNumber,
        gender: params.gender.value,
      );

      final response = await _authRemoteDataSource.signUp(request);

      return Success(
        RegisterEntity(
          message: response.message,
          messageLocalized: response.messageLocalized,
        ),
      );
    } catch (e) {
      final errMessage = ErrorHandler.extractErrorMessage(e);
      return Failure(errMessage);
    }
  }

}
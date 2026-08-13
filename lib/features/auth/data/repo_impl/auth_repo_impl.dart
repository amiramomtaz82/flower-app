import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:flower_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:flower_app/features/auth/data/models/login_request.dart';
import 'package:flower_app/features/auth/data/models/login_response.dart';
import 'package:flower_app/features/auth/domain/entities/login_entity.dart';
import 'package:flower_app/features/auth/domain/repo/auth_repo.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepo)
class AuthRepoImpl implements AuthRepo {
  final AuthRemoteDataSource _authRemoteDataSource;
  final AuthLocalDataSource _authLocalDataSource;

  AuthRepoImpl(
      this._authRemoteDataSource,
      this._authLocalDataSource,
      );

  @override
  Future<BaseResponse<LoginEntity>> login(
      LoginRequest request,
      ) async {
    final BaseResponse<LoginResponse> response =
    await _authRemoteDataSource.login(request);

    switch (response) {
      case SuccessResponse<LoginResponse>():
        final loginResponse = response.data;

        // Save access token
        if (loginResponse.accessToken != null) {
          await _authLocalDataSource.saveToken(
            loginResponse.accessToken!,
          );
        }

        // Save refresh token
        if (loginResponse.refreshToken != null) {
          await _authLocalDataSource.saveRefreshToken(
            loginResponse.refreshToken!,
          );
        }

        // Save user
        if (loginResponse.user != null) {
          await _authLocalDataSource.saveUser(
            loginResponse.user!,
          );
        }

        // Convert Data Model → Domain Entity
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
}
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:flower_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:flower_app/features/auth/data/models/LoginRequest.dart';
import 'package:flower_app/features/auth/data/models/LoginResponse.dart';
import 'package:flower_app/features/auth/domain/repo/auth_repo.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepo)
class AuthRepoImpl implements AuthRepo {
  final AuthRemoteDataSource _authRemoteDataSource;
  final AuthLocalDataSource _authLocalDataSource;

  AuthRepoImpl(this._authRemoteDataSource, this._authLocalDataSource);

  @override
  Future<BaseResponse<LoginResponse>> login(LoginRequest request) async {
    final BaseResponse<LoginResponse> response = await _authRemoteDataSource
        .login(request);

    switch (response) {
      case SuccessResponse<LoginResponse>():
        if (response.data.accessToken != null) {
          await _authLocalDataSource.saveToken(
            response.data.accessToken!,
          );
        }

        if (response.data.refreshToken != null) {
          await _authLocalDataSource.saveRefreshToken(
            response.data.refreshToken!,
          );
        }

        if (response.data.user != null) {
          await _authLocalDataSource.saveUser(
            response.data.user!,
          );
        }

        return SuccessResponse(response.data);
      case ErrorResponse<LoginResponse>():
        return ErrorResponse<LoginResponse>(errMessage: response.errMessage);
    }
  }
}
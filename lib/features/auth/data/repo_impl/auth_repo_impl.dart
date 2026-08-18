import 'package:dio/dio.dart';
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:flower_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:flower_app/features/auth/domain/entities/auth_message_entity.dart';
import 'package:flower_app/features/auth/domain/entities/reset_token_entity.dart';
import 'package:flower_app/features/auth/domain/repo/auth_repo.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepo)
class AuthRepoImpl implements AuthRepo {
  final AuthRemoteDataSource _authRemoteDataSource;
  final AuthLocalDataSource _authLocalDataSource;
  AuthRepoImpl(this._authRemoteDataSource, this._authLocalDataSource);

  // TODO: implement register

  // TODO: implement login

  @override
  Future<BaseResponse<AuthMessageEntity>> forgetPassword({
    required String email,
  }) async {
    try {
      final response = await _authRemoteDataSource.forgetPassword(email: email);
      return SuccessResponse(response.toEntity());
    } on DioException catch (e) {
      return ErrorResponse(error: e);
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
    } on DioException catch (e) {
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
      return SuccessResponse(response.toEntity());
    } on DioException catch (e) {
      return ErrorResponse(error: e);
    }
  }

  @override
  Future<void> clearAuthData() => _authLocalDataSource.clearAuthData();
}

import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:flower_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:flower_app/features/auth/data/models/register_request.dart';
import 'package:flower_app/features/auth/domain/entities/auth_entity.dart';
import 'package:flower_app/features/auth/domain/repo/auth_repo.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepo)
class AuthRepoImpl implements AuthRepo {
  final AuthRemoteDataSource _authRemoteDataSource;
  // ignore: unused_field — will be used by teammates for login/logout token management
  final AuthLocalDataSource _authLocalDataSource;

  AuthRepoImpl(this._authRemoteDataSource, this._authLocalDataSource);

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

  // TODO: implement login

  // TODO: implement forgetPassword

  // TODO: implement resetPassword
}

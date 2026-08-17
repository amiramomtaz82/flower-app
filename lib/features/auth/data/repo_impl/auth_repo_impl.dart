import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:flower_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:flower_app/features/auth/data/models/register_request.dart';
import 'package:flower_app/features/auth/domain/entities/auth_entity.dart';
import 'package:flower_app/features/auth/domain/entities/register_params.dart';
import 'package:flower_app/features/auth/domain/repo/auth_repo.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: AuthRepo)
class AuthRepoImpl implements AuthRepo {
  final AuthRemoteDataSource _authRemoteDataSource;
  // ignore: unused_field
  final AuthLocalDataSource _authLocalDataSource;

  AuthRepoImpl(this._authRemoteDataSource, this._authLocalDataSource);

  @override
  Future<BaseResponse<RegisterEntity>> signUp(RegisterParams params) async {
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

      return SuccessResponse(
        RegisterEntity(
          message: response.message,
          messageLocalized: response.messageLocalized,
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

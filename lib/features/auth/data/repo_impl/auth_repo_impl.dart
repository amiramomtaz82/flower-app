import 'package:flower_app/config/error/error_handler.dart';
import 'package:flower_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:flower_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:flower_app/features/auth/data/models/register_request.dart';
import 'package:flower_app/features/auth/domain/core/result.dart';
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

  // TODO: implement login

  // TODO: implement forgetPassword

  // TODO: implement resetPassword
}

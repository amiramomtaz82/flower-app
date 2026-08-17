import 'package:flower_app/features/auth/api/client/auth_api_client.dart';
import 'package:flower_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:flower_app/features/auth/data/models/register_request.dart';
import 'package:flower_app/features/auth/data/models/register_response.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthApiClient _authApiClient;

  AuthRemoteDataSourceImpl(this._authApiClient);

  @override
  Future<AuthResponse> signUp(SignUpRequest request) {
    return _authApiClient.register(request);
  }

  // TODO: implement login

  // TODO: implement forgetPassword

  // TODO: implement resetPassword
}

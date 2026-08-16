import '../../models/register_request.dart';
import '../../models/register_response.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthResponse> signUp(SignUpRequest request);

  // TODO: implement login

  // TODO: implement forgetPassword

  // TODO: implement resetPassword
}

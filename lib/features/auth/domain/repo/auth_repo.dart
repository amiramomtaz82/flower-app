import '../../../../config/base_response/base_response.dart';
import '../entities/auth_entity.dart';
import '../entities/register_params.dart';

abstract interface class AuthRepo {
  Future<BaseResponse<RegisterEntity>> signUp(RegisterParams params);

  // TODO: implement login

  // TODO: implement forgetPassword

  // TODO: implement resetPassword
}

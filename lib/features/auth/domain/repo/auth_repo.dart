import 'package:flower_app/config/base_response/base_response.dart';

import 'package:flower_app/features/auth/domain/entities/login_entity.dart';



import 'package:flower_app/features/auth/domain/core/result.dart';
import '../entities/auth_entity.dart';
import '../entities/register_params.dart';

abstract interface class AuthRepo {
  Future<BaseResponse<LoginEntity>> login({
    required String email,
    required String password,
  });
  Future<Result<RegisterEntity>> signUp(RegisterParams params);

  // TODO: implement login

  // TODO: implement forgetPassword

  // TODO: implement resetPassword
}

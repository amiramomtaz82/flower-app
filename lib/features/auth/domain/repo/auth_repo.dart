import 'package:flower_app/features/auth/domain/core/result.dart';
import '../entities/auth_entity.dart';
import '../entities/register_params.dart';

abstract interface class AuthRepo {
  Future<Result<RegisterEntity>> signUp(RegisterParams params);

  // TODO: implement login

  // TODO: implement forgetPassword

  // TODO: implement resetPassword
}

import 'package:flower_app/config/base_response/base_response.dart';

import 'package:flower_app/features/auth/domain/entities/login_entity.dart';



abstract interface class AuthRepo {
  Future<BaseResponse<LoginEntity>> login({
    required String email,
    required String password,
  });
}

import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/data/models/login_response.dart';
import 'package:flower_app/features/auth/domain/entities/login_entity.dart';

import '../../data/models/login_request.dart';

abstract interface class AuthRepo {
  Future<BaseResponse<LoginEntity>> login(LoginRequest request);
}

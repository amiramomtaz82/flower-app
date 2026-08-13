import 'package:flower_app/config/base_response/base_response.dart';

import '../../data/models/LoginRequest.dart';

abstract interface class AuthRepo {
  Future<BaseResponse<void>> login(LoginRequest request);
}

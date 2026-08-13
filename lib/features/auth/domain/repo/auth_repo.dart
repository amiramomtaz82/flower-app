import 'package:flower_app/config/base_response/base_response.dart';

import '../../data/models/login_request.dart';

abstract interface class AuthRepo {
  Future<BaseResponse<void>> login(LoginRequest request);
}

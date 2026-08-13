import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/domain/entities/login_entity.dart';
import 'package:flower_app/features/auth/domain/repo/auth_repo.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/login_request.dart';
import '../../data/models/login_response.dart';

@injectable
class LoginUseCase {
  final AuthRepo _authRepo;

  LoginUseCase(this._authRepo);
  Future<BaseResponse<LoginEntity>> call(LoginRequest request) {
    return _authRepo.login(request);
  }
}

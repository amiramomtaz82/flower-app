import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/domain/entities/auth_message_entity.dart';
import 'package:flower_app/features/auth/domain/repo/auth_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class ForgetPasswordUseCase {
  final AuthRepo _authRepo;
  ForgetPasswordUseCase(this._authRepo);

  Future<BaseResponse<AuthMessageEntity>> call({required String email}) {
    return _authRepo.forgetPassword(email: email);
  }
}

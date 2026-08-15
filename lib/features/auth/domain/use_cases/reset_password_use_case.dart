import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/domain/entities/auth_message_entity.dart';
import 'package:flower_app/features/auth/domain/repo/auth_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class ResetPasswordUseCase {
  final AuthRepo _authRepo;
  ResetPasswordUseCase(this._authRepo);

  Future<BaseResponse<AuthMessageEntity>> call({
    required String resetToken,
    required String newPassword,
    required String confirmNewPassword,
  }) {
    return _authRepo.resetPassword(
      resetToken: resetToken,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );
  }
}

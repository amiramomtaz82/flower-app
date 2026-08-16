import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/domain/entities/reset_token_entity.dart';
import 'package:flower_app/features/auth/domain/repo/auth_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class VerifyOtpUseCase {
  final AuthRepo _authRepo;
  VerifyOtpUseCase(this._authRepo);

  Future<BaseResponse<ResetToken>> call({
    required String email,
    required String otpCode,
  }) {
    return _authRepo.verifyOtp(email: email, otpCode: otpCode);
  }
}

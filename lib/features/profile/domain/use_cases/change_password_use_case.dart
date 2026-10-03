import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/profile/domain/entities/change_password_entity.dart';
import 'package:flower_app/features/profile/domain/repos/profile_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class ChangePasswordUseCase {
  final ProfileRepo _profileRepo;

  ChangePasswordUseCase(this._profileRepo);

  Future<BaseResponse<void>> call(ChangePasswordParams changePasswordParams) {
    return _profileRepo.changePassword(changePasswordParams);
  }
}

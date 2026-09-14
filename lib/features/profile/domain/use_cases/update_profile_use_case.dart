import 'package:flower_app/core/network/base_response.dart';
import 'package:flower_app/features/profile/domain/entities/profile_entity.dart';
import 'package:flower_app/features/profile/domain/entities/update_profile_entity.dart';
import 'package:flower_app/features/profile/domain/repos/profile_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateProfileUseCase {
  final ProfileRepo _profileRepo;
  UpdateProfileUseCase(this._profileRepo);
  Future<BaseResponse<ProfileEntity>> call(
    UpdateProfileEntity updateProfileEntity,
  ) {
    return _profileRepo.updateProfile(updateProfileEntity);
  }
}

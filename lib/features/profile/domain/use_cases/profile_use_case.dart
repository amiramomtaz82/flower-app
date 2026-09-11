import 'package:flower_app/core/network/base_response.dart';
import 'package:flower_app/features/profile/domain/entities/profile_entity.dart';
import 'package:flower_app/features/profile/domain/repos/profile_repo.dart';

class GetProfileUseCase {
  final ProfileRepo _profileRepo;
  GetProfileUseCase(this._profileRepo);
  Future<BaseResponse<ProfileEntity>> call() {
    return _profileRepo.getProfile();
  }
}

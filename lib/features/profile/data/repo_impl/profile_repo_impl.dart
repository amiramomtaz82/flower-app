import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/profile/data/data_source/remote/profile_remote_data_source.dart';
import 'package:flower_app/features/profile/domain/entities/profile_entity.dart';
import 'package:flower_app/features/profile/domain/repos/profile_repo.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: ProfileRepo)
class ProfileRepoImpl implements ProfileRepo {
  final ProfileRemoteDataSource _profileRemoteDataSource;

  ProfileRepoImpl(this._profileRemoteDataSource);

  @override
  Future<BaseResponse<ProfileEntity>> getProfile() async {
    try {
      final profile = await _profileRemoteDataSource.getProfile();
      return SuccessResponse(profile.toEntity());
    } catch (e) {
      return ErrorResponse(error: e);
    }
  }
}

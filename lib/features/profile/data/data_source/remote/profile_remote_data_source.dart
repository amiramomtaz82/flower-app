import 'package:flower_app/features/profile/data/models/change_password_dto.dart';
import 'package:flower_app/features/profile/data/models/profile_response_model.dart';
import 'package:flower_app/features/profile/data/models/update_profile_dto.dart';

abstract interface class ProfileRemoteDataSource {
  Future<ProfileResponseModel> getProfile();

  Future<ProfileResponseModel> updateProfile(
    UpdateProfileRequestDto updateProfileDto,
  );
  Future<void> changePassword(ChangePasswordRequestDto changePasswordDto);
}

import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/profile/domain/entities/change_password_entity.dart';
import 'package:flower_app/features/profile/domain/entities/profile_entity.dart';
import 'package:flower_app/features/profile/domain/entities/update_profile_entity.dart';

abstract interface class ProfileRepo {
  Future<BaseResponse<ProfileEntity>> getProfile();

  Future<BaseResponse<ProfileEntity>> updateProfile(
    UpdateProfileParams updateProfileEntity,
  );

  Future<BaseResponse<void>> changePassword(
    ChangePasswordParams changePasswordEntity,
  );
}

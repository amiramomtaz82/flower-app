import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/profile/domain/entities/profile_entity.dart';

abstract interface class ProfileRepo {
  Future<BaseResponse<ProfileEntity>> getProfile();
}

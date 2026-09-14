import 'package:flower_app/features/profile/domain/entities/update_profile_entity.dart';

sealed class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final UpdateProfileEntity updateProfileEntity;

  UpdateProfile(this.updateProfileEntity);
}

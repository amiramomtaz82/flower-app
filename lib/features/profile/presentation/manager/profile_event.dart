import 'package:flower_app/features/profile/domain/entities/change_password_entity.dart';
import 'package:flower_app/features/profile/domain/entities/update_profile_entity.dart';

sealed class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final UpdateProfileParams updateProfileEntity;

  UpdateProfile(this.updateProfileEntity);
}

class LogoutEvent extends ProfileEvent {}

class ChangePasswordEvent extends ProfileEvent {
  final ChangePasswordParams changePasswordEntity;

  ChangePasswordEvent(this.changePasswordEntity);
}

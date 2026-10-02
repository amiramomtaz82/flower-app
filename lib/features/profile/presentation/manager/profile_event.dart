import 'package:flower_app/features/profile/domain/entities/change_password_entity.dart';
import 'package:flower_app/features/profile/domain/entities/update_profile_entity.dart';

sealed class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final UpdateProfileEntity updateProfileEntity;

  UpdateProfile(this.updateProfileEntity);
}

class LogoutEvent extends ProfileEvent {}

class ChangePasswordEvent extends ProfileEvent {
  final ChangePasswordEntity changePasswordEntity;

  ChangePasswordEvent(this.changePasswordEntity);


}
//----------------------------------------------------
class ToggleNotification extends ProfileEvent {
  final bool enabled;
  ToggleNotification(this.enabled);
}
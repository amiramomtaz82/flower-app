import 'package:equatable/equatable.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/features/profile/domain/entities/profile_entity.dart';

class ProfileState extends Equatable {
  final Resource<ProfileEntity> resource;
  final Resource<ProfileEntity> updateProfileResource;
  final Resource<void> logoutResource;
  final Resource<void> changePasswordResource;

//-------------------------------------------------
  final bool notificationsEnabled;
  final Resource<void> toggleNotificationResource;

  const ProfileState({
    required this.resource,
    required this.updateProfileResource,
    required this.logoutResource,
    required this.changePasswordResource,
    required this.notificationsEnabled,
    required this.toggleNotificationResource,
  });

  factory ProfileState.initial() => ProfileState(
        resource: Resource.initial(),
        updateProfileResource: Resource.initial(),
        logoutResource: Resource.initial(),
        changePasswordResource: Resource.initial(),
        notificationsEnabled: true,
        toggleNotificationResource: Resource.initial(),
      );

  ProfileState copyWith({
    Resource<ProfileEntity>? resource,
    Resource<ProfileEntity>? updateProfileResource,
    Resource<void>? logoutResource,
    Resource<void>? changePasswordResource,
    bool? notificationsEnabled,
    Resource<void>? toggleNotificationResource,
  }) {
    return ProfileState(
      resource: resource ?? this.resource,
      updateProfileResource:
          updateProfileResource ?? this.updateProfileResource,
      logoutResource: logoutResource ?? this.logoutResource,
      changePasswordResource:
          changePasswordResource ?? this.changePasswordResource,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      toggleNotificationResource:
          toggleNotificationResource ?? this.toggleNotificationResource,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
        resource,
        updateProfileResource,
        logoutResource,
        changePasswordResource,
        notificationsEnabled,
        toggleNotificationResource
      ];
}

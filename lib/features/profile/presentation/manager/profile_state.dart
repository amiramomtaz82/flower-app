import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/features/profile/domain/entities/profile_entity.dart';

class ProfileState {
  final Resource<ProfileEntity> resource;
  final Resource<ProfileEntity> updateProfileResource;
  final Resource<void> logoutResource;

  const ProfileState({
    required this.resource,
    required this.updateProfileResource,
    required this.logoutResource,
  });

  factory ProfileState.initial() => ProfileState(
    resource: Resource.initial(),
    updateProfileResource: Resource.initial(),
    logoutResource: Resource.initial(),
  );

  ProfileState copyWith({
    Resource<ProfileEntity>? resource,
    Resource<ProfileEntity>? updateProfileResource,
    Resource<void>? logoutResource,
  }) {
    return ProfileState(
      resource: resource ?? this.resource,
      updateProfileResource:
          updateProfileResource ?? this.updateProfileResource,
      logoutResource: logoutResource ?? this.logoutResource,
    );
  }
}

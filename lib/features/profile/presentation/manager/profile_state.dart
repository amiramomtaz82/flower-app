import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/features/profile/domain/entities/profile_entity.dart';

class ProfileState {
  final Resource<ProfileEntity> resource;
  final Resource<ProfileEntity> updateProfileResource;

  const ProfileState({
    required this.resource,
    required this.updateProfileResource,
  });

  factory ProfileState.initial() => ProfileState(
        resource: Resource.initial(),
        updateProfileResource: Resource.initial(),
      );

  ProfileState copyWith({
    Resource<ProfileEntity>? resource,
    Resource<ProfileEntity>? updateProfileResource,
  }) {
    return ProfileState(
      resource: resource ?? this.resource,
      updateProfileResource:
          updateProfileResource ?? this.updateProfileResource,
    );
  }
}

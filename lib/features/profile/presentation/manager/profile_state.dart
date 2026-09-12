import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/features/profile/domain/entities/profile_entity.dart';

class ProfileState {
  final Resource<ProfileEntity> resource;

  const ProfileState({
    required this.resource,
  });

  ProfileState copyWith({
    Resource<ProfileEntity>? resource,
  }) {
    return ProfileState(
      resource: resource ?? this.resource,
    );
  }
}

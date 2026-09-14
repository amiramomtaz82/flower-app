import 'package:flower_app/features/profile/data/data_source/remote/profile_remote_data_source.dart';
import 'package:flower_app/features/profile/data/models/profile_response_model.dart';
import 'package:flower_app/features/profile/data/models/update_profile_dto.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: ProfileRemoteDataSource)
class MockProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  // 1. In-memory state holding the current profile
  static ProfileResponseModel _mockProfile = ProfileResponseModel(
    name: 'Hadi Heikal',
    email: 'HadiiRabea@gmail.com',
    profileImageUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
    gender: 'male',
    phoneNumber: '+201012345678',
  );

  @override
  Future<ProfileResponseModel> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockProfile; // Return current in-memory state
  }

  @override
  Future<ProfileResponseModel> updateProfile(
    UpdateProfileDto updateProfileDto,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // 2. Persist the update in memory!
    _mockProfile = ProfileResponseModel(
      name: updateProfileDto.fullName,
      email: updateProfileDto.email,
      profileImageUrl: updateProfileDto.photoUrl,
      gender: updateProfileDto.gender,
      phoneNumber: updateProfileDto.phoneNumber,
    );

    return _mockProfile;
  }
}

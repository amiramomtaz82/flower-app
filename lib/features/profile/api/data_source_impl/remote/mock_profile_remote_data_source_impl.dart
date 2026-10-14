import 'package:flower_app/features/profile/data/data_source/remote/profile_remote_data_source.dart';
import 'package:flower_app/features/profile/data/models/change_password_dto.dart';
import 'package:flower_app/features/profile/data/models/profile_response_model.dart';
import 'package:flower_app/features/profile/data/models/update_profile_dto.dart';

//@Injectable(as: ProfileRemoteDataSource)
class MockProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  // 1. In-memory state holding the current profile
  static ProfileResponseModel _mockProfile = ProfileResponseModel(
    id: 'mock_id',
    fullName: 'Hadi Heikal',
    email: 'HadiiRabea@gmail.com',
    photoUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
    gender: 'male',
    phone: '+201012345678',
  );

  @override
  Future<ProfileResponseModel> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockProfile; // Return current in-memory state
  }

  @override
  Future<ProfileResponseModel> updateProfile(
    UpdateProfileRequestDto updateProfileDto,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // 2. Persist the update in memory!
    _mockProfile = ProfileResponseModel(
      id: _mockProfile.id,
      fullName: updateProfileDto.fullName,
      email: updateProfileDto.email,
      photoUrl: updateProfileDto.photoPath ?? '',
      gender: updateProfileDto.gender,
      phone: updateProfileDto.phoneNumber,
    );

    return _mockProfile;
  }

  @override
  Future<void> changePassword(ChangePasswordRequestDto changePasswordDto) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Simulated successful password update
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }
}

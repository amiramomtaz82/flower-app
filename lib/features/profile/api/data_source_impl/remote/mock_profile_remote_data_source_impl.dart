import 'package:flower_app/features/profile/data/data_source/remote/profile_remote_data_source.dart';
import 'package:flower_app/features/profile/data/models/profile_response_model.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: ProfileRemoteDataSource)
class MockProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  @override
  Future<ProfileResponseModel> getProfile() async {
    // Simulate real-world network latency
    await Future.delayed(const Duration(milliseconds: 800));

    // Return realistic dummy profile data
    return ProfileResponseModel(
      name: 'Hadi Heikal',
      email: 'HadiiRabea@gmail.com',
      profileImageUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
      gender: 'male',
      phoneNumber: '+201012345678',
    );
  }
}

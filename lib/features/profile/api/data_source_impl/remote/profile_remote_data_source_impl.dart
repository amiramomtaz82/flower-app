import 'package:flower_app/features/profile/api/client/profile_api_client.dart';
import 'package:flower_app/features/profile/data/data_source/remote/profile_remote_data_source.dart';
import 'package:flower_app/features/profile/data/models/profile_response_model.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  // dependency injection for the ProfileApiClient
  final ProfileApiClient _profileApiClient;
  ProfileRemoteDataSourceImpl(this._profileApiClient);
  @override
  Future<ProfileResponseModel> getProfile() async {
    final response = await _profileApiClient.getProfile();
    return response;
  }
}

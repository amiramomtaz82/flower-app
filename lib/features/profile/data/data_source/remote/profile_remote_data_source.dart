import 'package:flower_app/features/profile/data/models/profile_response_model.dart';

abstract interface class ProfileRemoteDataSource {
  Future<ProfileResponseModel> getProfile();
}

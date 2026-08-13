import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/api/client/auth_api_client.dart';
import 'package:flower_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:flower_app/features/auth/data/models/LoginRequest.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/LoginResponse.dart';

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthApiClient _authApiClient;
  AuthRemoteDataSourceImpl(this._authApiClient);

  @override
  Future<BaseResponse<LoginResponse>> login (LoginRequest request) async{

    try {
      LoginResponse response = await _authApiClient.login(request);
      return SuccessResponse<LoginResponse>(response);
    } on Exception catch (e) {
      return ErrorResponse<LoginResponse>(error:e);
    }
  }

  }




import 'package:flower_app/config/base_response/base_response.dart';

import 'package:flower_app/features/Address/data/models/areas_with_city_response.dart';

import 'package:flower_app/features/Address/data/models/create_address_request.dart';
import 'package:flower_app/features/Address/data/models/create_address_response.dart';
import 'package:flower_app/features/Address/data/models/saved_addresses_response.dart';
import 'package:injectable/injectable.dart';

import '../../data/data_source/address_remote_data_source.dart';
import '../../data/models/addressdto.dart';

import '../client/address_api_client.dart';

@Injectable(as: AddressRemoteDataSource)
class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final AddressApiClient _apiClient;

  AddressRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BaseResponse<SavedAddressesResponse>> getSavedAddresses()async {
    try {
      final response = await _apiClient.getSavedAddresses();

      return SuccessResponse<SavedAddressesResponse>(response);
    } on Exception catch (e) {
      return ErrorResponse<SavedAddressesResponse>(error: e);
    }
  }

  @override
  Future<BaseResponse<CreateAddressResponse>> addAddress(
    CreateAddressRequest request,
      ) async{
    try {
      final response = await _apiClient.addAddress(request);

      return SuccessResponse<CreateAddressResponse>(response);
    } on Exception catch (e) {
      return ErrorResponse<CreateAddressResponse>(error: e);
    }
  }


  @override
  Future<BaseResponse<AreasWithCityResponse>> getCities() async {
    try {
      final response = await _apiClient.getAreas();

      return SuccessResponse<AreasWithCityResponse>(
        response,
      );
    } catch (e) {
      return ErrorResponse<AreasWithCityResponse>(error:e) ;



    }
  }
}
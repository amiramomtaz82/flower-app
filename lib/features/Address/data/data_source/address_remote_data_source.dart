

import 'package:flower_app/config/base_response/base_response.dart';

import '../models/areas_with_city_response.dart';
import '../models/create_address_request.dart';
import '../models/create_address_response.dart';
import '../models/saved_addresses_response.dart';
import '../models/set_default_address_response.dart';

abstract class AddressRemoteDataSource {


  Future<BaseResponse<CreateAddressResponse>> addAddress(CreateAddressRequest addressRequest);
  Future<BaseResponse<SavedAddressesResponse>> getSavedAddresses();
  Future<BaseResponse<CitiesWithAreasResponse>> getCities();
  Future<BaseResponse<CreateAddressResponse>> getAddressById(String addressId);
  Future<BaseResponse<CreateAddressResponse>> updateAddress(
      String addressId,
      CreateAddressRequest addressRequest,
      );

  Future<SetDefaultAddressResponse> setDefaultAddress(
      String addressId,
      );
}





import 'package:flower_app/config/base_response/base_response.dart';



import 'package:flower_app/features/Address/data/models/areas_with_city_response.dart';

import 'package:flower_app/features/Address/data/models/saved_addresses_response.dart';

import '../models/addressdto.dart';
import '../models/create_address_request.dart';
import '../models/create_address_response.dart';

abstract class AddressRemoteDataSource {


  Future<BaseResponse<CreateAddressResponse>> addAddress(CreateAddressRequest addressRequest);
  Future<BaseResponse<SavedAddressesResponse>> getSavedAddresses();
  Future<BaseResponse<AreasWithCityResponse>> getCities();

  Future<BaseResponse<AddressDto>> setDefaultAddress(String id);
}



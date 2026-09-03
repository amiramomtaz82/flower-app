import 'package:dio/dio.dart';

import 'package:flower_app/core/app_constants/endpoints.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../data/models/areas_with_city_response.dart';
import '../../data/models/create_address_request.dart';
import '../../data/models/create_address_response.dart';
import '../../data/models/saved_addresses_response.dart';
import '../../data/models/set_default_address_response.dart';
part 'address_api_client.g.dart';
@singleton
@RestApi()
abstract class AddressApiClient {
  @factoryMethod
  factory AddressApiClient(Dio dio) = _AddressApiClient;

@POST(Endpoints.addAddress)
  Future<CreateAddressResponse> addAddress(@Body() CreateAddressRequest addressRequest);

  @GET(Endpoints.addAddress)
  Future<SavedAddressesResponse> getSavedAddresses();

  @GET(Endpoints.getCities)
  Future<CitiesWithAreasResponse> getCities();

  @GET(Endpoints.addressById)
  Future<CreateAddressResponse> getAddressById(@Path('id') String id);

  @PUT(Endpoints.addressById)
  Future<CreateAddressResponse> updateAddress(
      @Path('id') String id,
      @Body() CreateAddressRequest addressRequest,
      );

@PUT(Endpoints.setDefaultAddress)
  Future<SetDefaultAddressResponse> setDefaultAddress(
      @Path('id') String id,
      );
}
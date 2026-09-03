import 'package:dio/dio.dart';

import 'package:flower_app/core/app_constants/endpoints.dart';

import 'package:flower_app/features/Address/data/models/areas_with_city_response.dart';

import 'package:flower_app/features/Address/data/models/create_address_request.dart';
import 'package:flower_app/features/Address/data/models/saved_addresses_response.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../data/models/create_address_response.dart';
part 'address_api_client.g.dart';
@singleton
@RestApi()
abstract class AddressApiClient {
  @factoryMethod
  factory AddressApiClient(Dio dio) = _AddressApiClient;

@POST(Endpoints.addAddress)
  Future<CreateAddressResponse> addAddress(@Body() CreateAddressRequest addressRequest);

  @GET(Endpoints.getAddresses)
  Future<SavedAddressesResponse> getSavedAddresses();

  @GET(Endpoints.getAreas)
  Future<AreasWithCityResponse> getAreas();
}
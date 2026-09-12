import 'package:flower_app/core/location/location_model.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/network/base_response.dart';
import '../entities/add_address_entity.dart';
import '../entities/address_entity.dart';
import '../entities/area_entity.dart';

abstract interface class AddressRepo {
  Future<BaseResponse<List<AddressEntity>>> getSavedAddresses();
  Future<BaseResponse<AddressEntity>> addAddress(AddAddressEntity address);
  Future<BaseResponse<List<AreaEntity>>> getAreasWithCities();
  Future<BaseResponse<AddressEntity>> setDefaultAddress(String id);

  // Added Location methods
  Future<BaseResponse<LatLng>> getCurrentLocation({bool requestIfDenied = true});
  Future<BaseResponse<LocationModel>> reverseGeocode({
    required double lat,
    required double lng,
  });

  Future<BaseResponse<AddressEntity>> updateAddress({
    required String id,
    required AddressEntity address,
  });

  Future<BaseResponse<void>> deleteAddress(String id);
}


import '../../../../core/network/base_response.dart';
import '../entities/add_address_entity.dart';
import '../entities/address_entity.dart';
import '../entities/city_entity.dart';

abstract class AddressRepo{


  Future<BaseResponse<List<AddressEntity>>> getSavedAddresses();
  Future<BaseResponse<AddressEntity>> addAddress(AddAddressEntity address);

  /// Returns cities, each carrying its nested areas.
  Future<BaseResponse<List<CityEntity>>> getAreasWithCities();

  Future<BaseResponse<AddressEntity>> setDefaultAddress(
      String addressId,
      );

  Future<BaseResponse<AddressEntity>> getAddressById(String addressId);

  Future<BaseResponse<AddressEntity>> updateAddress(
      String addressId,
      AddAddressEntity address,
      );

}
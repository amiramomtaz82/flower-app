

import '../../../../core/network/base_response.dart';
import '../entities/add_address_entity.dart';
import '../entities/address_entity.dart';
import '../entities/area_entity.dart';
import '../entities/city_entity.dart';

abstract class AddressRepo{


  Future<BaseResponse<List<AddressEntity>>> getSavedAddresses();
  Future<BaseResponse<AddressEntity>> addAddress(AddAddressEntity address);

  Future<BaseResponse<List<AreaEntity>>> getAreasWithCities();

  Future<BaseResponse<AddressEntity>> setDefaultAddress(
      String addressId,
      );

}
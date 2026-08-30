import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/Address/data/models/areas_with_city_response.dart';
import 'package:flower_app/features/Address/data/models/create_address_request.dart';
import 'package:flower_app/features/Address/data/models/saved_addresses_response.dart';
import 'package:injectable/injectable.dart';

import '../../data/data_source/address_remote_data_source.dart';

import '../../domain/entities/add_address_entity.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/area_entity.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/repo/address_repo.dart';
import '../models/create_address_response.dart';


@LazySingleton(as: AddressRepo)
class AddressRepoImpl implements AddressRepo {
  final AddressRemoteDataSource _remoteDataSource;

  AddressRepoImpl(this._remoteDataSource);

  @override
  Future<BaseResponse<List<AddressEntity>>> getSavedAddresses() async {
    final response = await _remoteDataSource.getSavedAddresses();

    switch (response) {
      case SuccessResponse<SavedAddressesResponse>():
        final addresses = response.data.data
            ?.map((dto) => dto.toEntity())
            .toList() ??
            [];

        return SuccessResponse<List<AddressEntity>>(addresses);

      case ErrorResponse<SavedAddressesResponse>():
        return ErrorResponse<List<AddressEntity>>(
          error: response.error,
        );
    }

  }

  @override
  Future<BaseResponse<AddressEntity>> addAddress(
      AddAddressEntity address,
      ) async {
    final request = CreateAddressRequest(
      recipientName: address.recipientName,
     phone: address.recipientPhone,
      addressLine: address.addressLine,
     cityId: address.city,
     areaId: address.area,
     latitude: address.lat,
      longitude: address.lng,
      label: address.label,
    );

    final response = await _remoteDataSource.addAddress(request);

    switch (response) {
      case SuccessResponse<CreateAddressResponse>():
        return SuccessResponse<AddressEntity>(
          response.data.data!.toEntity(),
        );

      case ErrorResponse<CreateAddressResponse>():
        return ErrorResponse<AddressEntity>(
          error: response.error,
        );
    }
  }




  Future<BaseResponse<List<AreaEntity>>> getAreasWithCities() async {
    final result = await _remoteDataSource.getCities();

    switch (result) {
      case SuccessResponse<AreasWithCityResponse>():
        final response = result.data;

        if (response ==null || response.data == null) {
          return ErrorResponse<List<AreaEntity>>(
            error: 'Areas response is empty',
          );
        }

        return SuccessResponse<List<AreaEntity>>(
          response.data!
              .map((areaDto) => areaDto.toEntity())
              .toList(),
        );

      case ErrorResponse<AreasWithCityResponse>():
        return ErrorResponse<List<AreaEntity>>(
          error: result.errMessage,
        );
    }
  }

  //-------------set default address------------------

  @override
  Future<BaseResponse<AddressEntity>> setDefaultAddress(
      String addressId,
      ) async {
    try {
      final response =
      await _remoteDataSource.setDefaultAddress(addressId);

      if (response.isSuccess == true && response.data != null) {
        return SuccessResponse<AddressEntity>(
           response.data!.toEntity(),
        );
      }

      return ErrorResponse<AddressEntity>(
        error: response.message ?? 'Failed to set default address',
      );
    } catch (e) {
      return ErrorResponse<AddressEntity>(
        error: e.toString(),
      );
    }
  }
}
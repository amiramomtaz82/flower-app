import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/location/location_model.dart';
import 'package:flower_app/features/Address/data/models/areas_with_city_response.dart';
import 'package:flower_app/features/Address/data/models/create_address_request.dart';
import 'package:flower_app/features/Address/data/models/saved_addresses_response.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/location/location_service.dart';
import '../../data/data_source/address_remote_data_source.dart';

import '../../domain/entities/add_address_entity.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/area_entity.dart';

import '../../domain/repo/address_repo.dart';
import '../models/address_dto.dart';
import '../models/create_address_response.dart';


@Injectable(as: AddressRepo)
class AddressRepoImpl implements AddressRepo {
  final AddressRemoteDataSource _remoteDataSource;

  final LocationService _locationService;

  AddressRepoImpl(this._remoteDataSource, this._locationService);

  @override
  Future<BaseResponse<List<AddressEntity>>> getSavedAddresses() async {
    final response = await _remoteDataSource.getSavedAddresses();

    switch (response) {
      case SuccessResponse<SavedAddressesResponse>():
        final addressDtos = response.data
            ?.data; // Safely access inner data list

        final addresses = addressDtos
            ?.map((dto) => dto.toEntity())
            .toList() ??
            <AddressEntity>[];

        return SuccessResponse<List<AddressEntity>>(addresses);

      case ErrorResponse<SavedAddressesResponse>():
        return ErrorResponse<List<AddressEntity>>(
          error: response.error,
          errMessage: response.errMessage,
        );
    }
  }

  @override
  Future<BaseResponse<AddressEntity>> addAddress(
      AddAddressEntity address,) async {
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
        final addressData = response.data.data;
        if (addressData != null) {
          return SuccessResponse<AddressEntity>(addressData.toEntity());
        }
        return ErrorResponse<AddressEntity>(
          error: 'Missing address data',
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

        if (response == null || response.data == null) {
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

  @override
  Future<BaseResponse<AddressEntity>> setDefaultAddress(String id) async {
    final response = await _remoteDataSource.setDefaultAddress(id);

    switch (response) {
      case SuccessResponse<AddressDto>():
        final dto = response.data;
        if (dto != null) {
          return SuccessResponse<AddressEntity>(dto.toEntity());
        }
        return ErrorResponse<AddressEntity>(error: 'Missing address data');
      case ErrorResponse<AddressDto>():
        return ErrorResponse<AddressEntity>(error: response.error);
    }
  }


  @override
  Future<BaseResponse<LatLng>> getCurrentLocation({bool requestIfDenied = true}) async {
    try {
      final serviceEnabled = await _locationService.isServiceEnabled();
      if (!serviceEnabled) {
        return ErrorResponse<LatLng>(errMessage: 'Location services are disabled');
      }

      var permission = await _locationService.checkPermission();

      if (permission == LocationPermission.denied && requestIfDenied) {
        permission = await _locationService.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return ErrorResponse<LatLng>(errMessage: 'Location permissions denied');
      }

      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        return SuccessResponse<LatLng>(position);
      }

      return ErrorResponse<LatLng>(errMessage: 'Failed to obtain position coordinates');
    } catch (e) {
      return ErrorResponse<LatLng>(error: e);
    }
  }
  @override
  Future<BaseResponse<LocationModel>> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    try {
      final details = await _locationService.reverseGeocode(lat: lat, lng: lng);
      if (details != null) {
        return SuccessResponse<LocationModel>(details);
      }
      return ErrorResponse<LocationModel>(error: 'Could not reverse geocode');
    } catch (e) {
      return ErrorResponse<LocationModel>(error: e.toString());
    }
  }
}
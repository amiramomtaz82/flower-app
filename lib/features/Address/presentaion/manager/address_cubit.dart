import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../../config/base_response/base_response.dart';
import '../../../../../config/resource/rsource.dart';
import '../../../../core/location/location_service.dart';
import '../../../auth/data/data_source/local/auth_local_data_source.dart';
import '../../api/data_source/address_local_data_source_imp.dart';
import '../../domain/entities/add_address_entity.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/area_entity.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/use_cases/add_address_usecase.dart';
import '../../domain/use_cases/get_area_with_city_usecase.dart';
import '../../domain/use_cases/get_saved_address_useacse.dart';
import '../../domain/use_cases/set_default_address_usecase.dart';
import 'address_events.dart';
import 'address_state.dart';

@LazySingleton()
class AddressCubit extends Cubit<AddressState> {
  final GetSavedAddressesUseCase _getSavedAddressesUseCase;
  final AddAddressUseCase _addAddressUseCase;
  final LocationService _locationService;
  final GetAreasWithCitiesUseCase _getAreasWithCitiesUseCase;
  final SetDefaultAddressUseCase _setDefaultAddressUseCase;
  final AuthLocalDataSource _authLocalDataSource;

  AddressCubit(
      this._getAreasWithCitiesUseCase,
      this._getSavedAddressesUseCase,
      this._addAddressUseCase,
      this._locationService,
      this._setDefaultAddressUseCase,
      this._authLocalDataSource
      ) : super(AddressState.initial());

  Future<void> doEvents(AddressEvent event) async {
    switch (event) {
      case GetSavedAddressesEvent():
        await _getSavedAddresses();
      case GetAreasWithCitiesEvent():
        await _getAreasWithCities();
      case InitializeAddressEvent():
        await _initializeAddress();

      case AddAddressEvent():
        await _addAddress(event.address);

      case SelectAddressEvent():
        _selectAddress(event.address);

      case GetCurrentLocationEvent():
        await _getCurrentLocation();

      case SelectLocationEvent():
        await _selectLocation(event.location);

      case SelectCityEvent():
        _selectCity(event.city);

      case SelectAreaEvent():
        _selectArea(event.area);

      case SetDefaultAddressEvent():
        await _setDefaultAddress(event.addressId);

case InitializeHomeAddressEvent():
    await _initializeHomeAddress();
    }
  }

  Future<void> _setDefaultAddress(String addressId) async {
    final result = await _setDefaultAddressUseCase(addressId);

    switch (result) {
      case SuccessResponse<AddressEntity>():
        final updatedAddress = result.data;

        if (updatedAddress == null) {
          return;
        }

        final updatedAddresses = state.addresses.map((address) {
          if (address.id == updatedAddress.id) {
            return updatedAddress;
          }

          return AddressEntity(
            id: address.id,
            recipientName: address.recipientName,
            recipientPhone: address.recipientPhone,
            addressLine: address.addressLine,
            cityId: address.cityId,
            areaId: address.areaId,
            lat: address.lat,
            lng: address.lng,
            label: address.label,
            isDefault: false,
            storeId: address.storeId,
            isServiceable: address.isServiceable,
            createdAt: address.createdAt,
          );
        }).toList();

        emit(
          state.copyWith(
            addresses: updatedAddresses,
            selectedAddress: updatedAddress,
          ),
        );

      case ErrorResponse<AddressEntity>():
        debugPrint(
          'Set default address error: ${result.errMessage}',
        );
    }
  }
  Future<void> _getAreasWithCities() async {
    emit(
      state.copyWith(
        areaResource: Resource.loading(),
      ),
    );

    try {
      final result = await _getAreasWithCitiesUseCase();

      switch (result) {
        case SuccessResponse<List<AreaEntity>>():
          final areas = result.data ?? [];

          if (areas.isNotEmpty) {
            debugPrint('========== AREAS API SUCCESS ==========');
            debugPrint('Areas count: ${areas.length}');

            emit(
              state.copyWith(
                areas: areas,
                areaResource: Resource.success(areas),
              ),
            );
          } else {
            debugPrint('========== API EMPTY ==========');
            debugPrint('Using local fallback areas');

            emit(
              state.copyWith(
                areas: cityAreaData,
                areaResource: Resource.success(cityAreaData),
              ),
            );
          }

        case ErrorResponse<List<AreaEntity>>():
          debugPrint('========== AREAS API ERROR ==========');
          debugPrint('Error: ${result.errMessage}');
          debugPrint('Using local fallback areas');

          emit(
            state.copyWith(
              areas: cityAreaData,
              areaResource: Resource.success(cityAreaData),
            ),
          );
      }
    } catch (e) {
      debugPrint('========== AREAS API EXCEPTION ==========');
      debugPrint('Exception: $e');
      debugPrint('Using local fallback areas');

      emit(
        state.copyWith(
          areas: cityAreaData,
          areaResource: Resource.success(cityAreaData),
        ),
      );
    }
  }

  // ============================================================
  // GET SAVED ADDRESSES
  // ============================================================

  Future<void> _getSavedAddresses() async {
    emit(
      state.copyWith(
        getAddressesResource: Resource.loading(),
      ),
    );

    final result = await _getSavedAddressesUseCase();

    switch (result) {
      case SuccessResponse<List<AddressEntity>>():
        final addresses = result.data ?? [];

        emit(
          state.copyWith(
            addresses: addresses,
            getAddressesResource: Resource.success(addresses),
          ),
        );

      case ErrorResponse<List<AddressEntity>>():
        emit(
          state.copyWith(
            getAddressesResource: Resource.error(
              result.errMessage,
            ),
          ),
        );
    }
  }

  // ============================================================
  // ADD ADDRESS
  // ============================================================

  Future<void> _addAddress(
      AddAddressEntity address,
      ) async {
    emit(
      state.copyWith(
        addAddressResource: Resource.loading(),
      ),
    );

    final result = await _addAddressUseCase(address);

    switch (result) {
      case SuccessResponse<AddressEntity>():
        final newAddress = result.data;

        if (newAddress == null) {
          emit(
            state.copyWith(
              addAddressResource: Resource.error(
                'Address was not created',
              ),
            ),
          );
          return;
        }

        final updatedAddresses = [
          ...state.addresses,
          newAddress,
        ];

        emit(
          state.copyWith(
            addresses: updatedAddresses,
            selectedAddress: newAddress,
            addAddressResource: Resource.success(newAddress),
          ),
        );

      case ErrorResponse<AddressEntity>():
        emit(
          state.copyWith(
            addAddressResource: Resource.error(
              result.errMessage,
            ),
          ),
        );
    }
  }



  void _selectAddress(AddressEntity address) {
    emit(
      state.copyWith(
        selectedAddress: address,
      ),
    );
  }



  Future<void> _getCurrentLocation() async {
    try {
      final location = await _locationService.getCurrentLocation();

      await _selectLocation(location);
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }


  String _normalize(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }
    return value
        .toLowerCase()
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }




  Future<void> _selectLocation(LatLng location) async {
    debugPrint('========== _SELECT LOCATION ==========');

    emit(
      state.copyWith(
        selectedLocation: location,
      ),
    );

    try {
      final locationDetails = await _locationService.reverseGeocode(
        lat: location.latitude,
        lng: location.longitude,
      );

      debugPrint('========== REVERSE GEOCODING ==========');
      debugPrint('Latitude: ${location.latitude}');
      debugPrint('Longitude: ${location.longitude}');
      debugPrint('Address: ${locationDetails.addressLine}');
      debugPrint('State: ${locationDetails.state}');
      debugPrint('City: ${locationDetails.city}');
      debugPrint('Town: ${locationDetails.town}');
      debugPrint('Municipality: ${locationDetails.municipality}');
      debugPrint('Suburb: ${locationDetails.suburb}');
      debugPrint('Neighbourhood: ${locationDetails.neighbourhood}');
      debugPrint('========================================');

      // ============================================================
      // 1. FIND BACKEND AREA
      // ============================================================

      final areaName = locationDetails.state ??
          locationDetails.city ??
          locationDetails.town ??
          locationDetails.municipality;

      final normalizedAreaName = _normalize(areaName);

      AreaEntity? matchedArea;

      for (final area in state.areas) {
        if (_normalize(area.name) == normalizedAreaName) {
          matchedArea = area;
          break;
        }
      }

      // ============================================================
      // 2. FIND BACKEND CITY
      // ============================================================

      final cityName = locationDetails.suburb ??
          locationDetails.neighbourhood;

      final normalizedCityName = _normalize(cityName);

      CityEntity? matchedCity;

      if (matchedArea != null && normalizedCityName.isNotEmpty) {
        for (final city in matchedArea.cities) {
          if (_normalize(city.name) == normalizedCityName) {
            matchedCity = city;
            break;
          }
        }
      }

      // ============================================================
      // DEBUG
      // ============================================================

      debugPrint('========== MATCHING RESULT ==========');
      debugPrint('Nominatim Area: $areaName');
      debugPrint('Nominatim City: $cityName');

      debugPrint('Matched area: ${matchedArea?.name}');
      debugPrint('Matched area ID: ${matchedArea?.id}');

      debugPrint('Matched city: ${matchedCity?.name}');
      debugPrint('Matched city ID: ${matchedCity?.id}');
      debugPrint('=====================================');

      // ============================================================
      // 3. UPDATE STATE
      // ============================================================

      emit(
        state.copyWith(
          selectedLocation: location,
          selectedLocationDetails: locationDetails,
          selectedArea: matchedArea,
          selectedCity: matchedCity,
        ),
      );
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
    }
  }


  void _selectCity(CityEntity city) {
    emit(
      state.copyWith(
        selectedCity: city,
      ),
    );
  }



  void _selectArea(AreaEntity area) {
    emit(
      AddressState(
        addresses: state.addresses,
        selectedAddress: state.selectedAddress,
        getAddressesResource: state.getAddressesResource,
        addAddressResource: state.addAddressResource,
        areaResource: state.areaResource,
        selectedLocation: state.selectedLocation,
        selectedLocationDetails: state.selectedLocationDetails,
        areas: state.areas,
        selectedArea: area,
        selectedCity: null,
      ),
    );
  }

  List<AreaEntity> get filteredAreas {
    final selectedCity = state.selectedCity;

    // Nothing selected → show ALL areas
    if (selectedCity == null) {
      return state.areas;
    }

    // City selected → show areas containing that city
    return state.areas.where((area) {
      return area.cities.any(
            (city) => city.id == selectedCity.id,
      );
    }).toList();
  }
  List<CityEntity> get filteredCities {
    final selectedArea = state.selectedArea;

    if (selectedArea == null) {
      return [];
    }

    return selectedArea.cities;
  }


  Future<void> _initializeAddress() async {
    await _getAreasWithCities();

    await _getCurrentLocation();

    await _getSavedAddresses();
  }
  List<CityEntity> _getAllCities() {
    final cityMap = <String, CityEntity>{};

    for (final area in state.areas) {
      for (final city in area.cities) {
        if (city.id != null) {
          cityMap[city.id!] = city;
        }
      }
    }

    return cityMap.values.toList();
  }

//----------------------------------
  void _selectDefaultAddress() {
    AddressEntity? defaultAddress;

    for (final address in state.addresses) {
      if (address.isDefault == true) {
        defaultAddress = address;
        break;
      }
    }

    if (defaultAddress == null) {
      debugPrint('No default address found.');
      return;
    }

    debugPrint(
      'Using default address: ${defaultAddress.addressLine}',
    );

    _selectAddress(defaultAddress);
  }
  Future<void> _selectBestAddress() async {
    final addresses = state.addresses;

    if (addresses.isEmpty) {
      return;
    }

    try {
      // Get user's current GPS location
      final currentLocation =
      await _locationService.getCurrentLocation();

      final distance = Distance();

      AddressEntity? nearestAddress;
      double? nearestDistance;

      for (final address in addresses) {
        // Skip addresses without coordinates
        if (address.lat == null || address.lng == null) {
          continue;
        }

        final addressLocation = LatLng(
          address.lat!,
          address.lng!,
        );

        final distanceInMeters = distance.as(
          LengthUnit.Meter,
          currentLocation,
          addressLocation,
        );

        if (nearestDistance == null ||
            distanceInMeters < nearestDistance!) {
          nearestDistance = distanceInMeters;
          nearestAddress = address;
        }
      }

      // No valid address with coordinates
      if (nearestAddress == null || nearestDistance == null) {
        debugPrint(
          'HOME ADDRESS: No address has valid coordinates',
        );

        _selectDefaultAddress();
        return;
      }

      debugPrint('========== HOME ADDRESS ==========');
      debugPrint(
        'Current location: '
            '${currentLocation.latitude}, '
            '${currentLocation.longitude}',
      );
      debugPrint(
        'Nearest address: ${nearestAddress.addressLine}',
      );
      debugPrint(
        'Distance: ${nearestDistance.toStringAsFixed(0)} meters',
      );
      debugPrint('==================================');

      // Maximum distance allowed for automatic selection
      const maxDistanceInMeters = 10000.0;

      if (nearestDistance <= maxDistanceInMeters) {
        debugPrint(
          'HOME ADDRESS: Nearest address selected',
        );

        _selectAddress(nearestAddress);
      } else {
        debugPrint(
          'HOME ADDRESS: Nearest address is too far',
        );

        _selectDefaultAddress();
      }
    } catch (e) {
      // GPS unavailable / permission denied / location service disabled
      debugPrint(
        'HOME ADDRESS: GPS unavailable: $e',
      );

      _selectDefaultAddress();
    }
  }

  Future<void> _initializeHomeAddress() async {
    final token = await _authLocalDataSource.getToken();

    // Guest user
    if (token == null || token.isEmpty) {
      debugPrint('HOME ADDRESS: Guest user');
      return;
    }

    // Logged-in user
    debugPrint('HOME ADDRESS: Logged-in user');

    await _getSavedAddresses();

    if (state.addresses.isEmpty) {
      debugPrint('HOME ADDRESS: No saved addresses');
      return;
    }

    await _selectBestAddress();
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../../config/base_response/base_response.dart';
import '../../../../../config/resource/rsource.dart';
import '../../../../core/location/location_service.dart';
import '../../../auth/data/data_source/local/auth_local_data_source.dart';
import '../../domain/entities/add_address_entity.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/area_entity.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/use_cases/add_address_usecase.dart';
import '../../domain/use_cases/get_address_by_id_usecase.dart';
import '../../domain/use_cases/get_area_with_city_usecase.dart';
import '../../domain/use_cases/get_saved_address_useacse.dart';
import '../../domain/use_cases/set_default_address_usecase.dart';
import '../../domain/use_cases/update_address_usecase.dart';
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
  final GetAddressByIdUseCase _getAddressByIdUseCase;
  final UpdateAddressUseCase _updateAddressUseCase;

  AddressCubit(
      this._getAreasWithCitiesUseCase,
      this._getSavedAddressesUseCase,
      this._addAddressUseCase,
      this._locationService,
      this._setDefaultAddressUseCase,
      this._authLocalDataSource,
      this._getAddressByIdUseCase,
      this._updateAddressUseCase,
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

      case GetAddressByIdEvent():
        await _getAddressById(event.addressId);

      case UpdateAddressEvent():
        await _updateAddress(event.addressId, event.address);

      case PrefillAddressForEditEvent():
        _prefillAddressForEdit(event.address);
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
    final result = await _getAreasWithCitiesUseCase();

    switch (result) {
      case SuccessResponse<List<CityEntity>>():
        final cities = result.data;

        debugPrint('========== CITIES LOADED ==========');
        debugPrint('Cities count: ${cities.length}');

        for (final city in cities) {
          debugPrint('CITY: ${city.name}');

          for (final area in city.areas) {
            debugPrint('   AREA: ${area.name}');
          }
        }

        debugPrint('==================================');

        emit(
          state.copyWith(
            cities: cities,
          ),
        );

      case ErrorResponse<List<CityEntity>>():
        debugPrint(
          'Get cities error: ${result.errMessage}',
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

  // ============================================================
  // SELECT SAVED ADDRESS
  // ============================================================

  void _selectAddress(AddressEntity address) {
    emit(
      state.copyWith(
        selectedAddress: address,
      ),
    );
  }

  // ============================================================
  // GET CURRENT LOCATION
  // ============================================================

  Future<void> _getCurrentLocation() async {
    try {
      final location = await _locationService.getCurrentLocation();

      await _selectLocation(location);
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  // ============================================================
  // NORMALIZE
  // ============================================================

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


  // ============================================================
  // SELECT LOCATION
  // ============================================================

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
      // 1. FIND BACKEND CITY
      // ============================================================

      final cityName = locationDetails.state ??
          locationDetails.city ??
          locationDetails.town ??
          locationDetails.municipality;

      final normalizedCityName = _normalize(cityName);

      CityEntity? matchedCity;

      for (final city in state.cities) {
        if (_normalize(city.name) == normalizedCityName) {
          matchedCity = city;
          break;
        }
      }

      // ============================================================
      // 2. FIND BACKEND AREA
      // ============================================================

      final areaName = locationDetails.suburb ??
          locationDetails.neighbourhood;

      final normalizedAreaName = _normalize(areaName);

      AreaEntity? matchedArea;

      if (matchedCity != null && normalizedAreaName.isNotEmpty) {
        for (final area in matchedCity.areas) {
          if (_normalize(area.name) == normalizedAreaName) {
            matchedArea = area;
            break;
          }
        }
      }

      // ============================================================
      // DEBUG
      // ============================================================

      debugPrint('========== MATCHING RESULT ==========');
      debugPrint('Nominatim City: $cityName');
      debugPrint('Nominatim Area: $areaName');

      debugPrint('Matched city: ${matchedCity?.name}');
      debugPrint('Matched city ID: ${matchedCity?.id}');

      debugPrint('Matched area: ${matchedArea?.name}');
      debugPrint('Matched area ID: ${matchedArea?.id}');
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
  // ============================================================
  // SELECT CITY
  // ============================================================

  void _selectCity(CityEntity city) {
    // Selecting a new city invalidates any previously picked area, since
    // areas belong to exactly one city.
    final stillValidArea = state.selectedArea != null &&
        city.areas.any((area) => area.id == state.selectedArea!.id);

    emit(
      AddressState(
        addresses: state.addresses,
        selectedAddress: state.selectedAddress,
        getAddressesResource: state.getAddressesResource,
        addAddressResource: state.addAddressResource,
        selectedLocation: state.selectedLocation,
        selectedLocationDetails: state.selectedLocationDetails,
        cities: state.cities,
        selectedCity: city,
        selectedArea: stillValidArea ? state.selectedArea : null,
        addressDetails: state.addressDetails,
        getAddressByIdResource: state.getAddressByIdResource,
        updateAddressResource: state.updateAddressResource,
      ),
    );
  }

  // ============================================================
  // SELECT AREA
  // ============================================================

  void _selectArea(AreaEntity area) {
    emit(
      state.copyWith(
        selectedArea: area,
      ),
    );
  }

  /// Areas belonging to the currently selected city — empty until a city
  /// is chosen, since a standalone area can't be resolved to a city.
  List<AreaEntity> get filteredAreas {
    return state.selectedCity?.areas ?? [];
  }


  Future<void> _initializeAddress() async {
    await _getAreasWithCities();

    await _getCurrentLocation();

    await _getSavedAddresses();
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

  // ============================================================
  // PREFILL ADDRESS FOR EDIT
  // ============================================================

  void _prefillAddressForEdit(AddressEntity address) {
    CityEntity? matchedCity;
    AreaEntity? matchedArea;

    for (final city in state.cities) {
      if (city.id == address.cityId) {
        matchedCity = city;

        for (final area in city.areas) {
          if (area.id == address.areaId) {
            matchedArea = area;
            break;
          }
        }

        break;
      }
    }

    LatLng? location;

    if (address.lat != null && address.lng != null) {
      location = LatLng(address.lat!, address.lng!);
    }

    // AddressState.copyWith can't null a field back out (a null argument
    // just keeps the old value), so this is built directly to guarantee a
    // stale selection from an earlier screen doesn't leak into this one —
    // AddressCubit is a shared singleton across the app.
    emit(
      AddressState(
        addresses: state.addresses,
        selectedAddress: state.selectedAddress,
        getAddressesResource: state.getAddressesResource,
        addAddressResource: state.addAddressResource,
        selectedLocation: location,
        selectedLocationDetails: state.selectedLocationDetails,
        cities: state.cities,
        selectedCity: matchedCity,
        selectedArea: matchedArea,
        addressDetails: state.addressDetails,
        getAddressByIdResource: state.getAddressByIdResource,
        updateAddressResource: state.updateAddressResource,
      ),
    );
  }

  // ============================================================
  // GET ADDRESS BY ID
  // ============================================================

  Future<void> _getAddressById(String addressId) async {
    emit(
      state.copyWith(
        getAddressByIdResource: Resource.loading(),
      ),
    );

    final result = await _getAddressByIdUseCase(addressId);

    switch (result) {
      case SuccessResponse<AddressEntity>():
        final address = result.data;

        emit(
          state.copyWith(
            addressDetails: address,
            getAddressByIdResource: Resource.success(address),
          ),
        );

      case ErrorResponse<AddressEntity>():
        emit(
          state.copyWith(
            getAddressByIdResource: Resource.error(
              result.errMessage,
            ),
          ),
        );
    }
  }

  // ============================================================
  // UPDATE ADDRESS
  // ============================================================

  Future<void> _updateAddress(
      String addressId,
      AddAddressEntity address,
      ) async {
    emit(
      state.copyWith(
        updateAddressResource: Resource.loading(),
      ),
    );

    final result = await _updateAddressUseCase(addressId, address);

    switch (result) {
      case SuccessResponse<AddressEntity>():
        final updatedAddress = result.data;

        final updatedAddresses = state.addresses.map((existing) {
          return existing.id == updatedAddress.id
              ? updatedAddress
              : existing;
        }).toList();

        emit(
          state.copyWith(
            addresses: updatedAddresses,
            addressDetails: updatedAddress,
            updateAddressResource: Resource.success(updatedAddress),
          ),
        );

      case ErrorResponse<AddressEntity>():
        emit(
          state.copyWith(
            updateAddressResource: Resource.error(
              result.errMessage,
            ),
          ),
        );
    }
  }
}
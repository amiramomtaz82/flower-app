import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../../config/base_response/base_response.dart';
import '../../../../../config/resource/rsource.dart';
import '../../../../core/location/location_service.dart';
import '../../domain/entities/add_address_entity.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/area_entity.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/use_cases/add_address_usecase.dart';
import '../../domain/use_cases/get_area_with_city_usecase.dart';
import '../../domain/use_cases/get_saved_address_useacse.dart';
import 'address_events.dart';
import 'address_state.dart';

@LazySingleton()
class AddressCubit extends Cubit<AddressState> {
  final GetSavedAddressesUseCase _getSavedAddressesUseCase;
  final AddAddressUseCase _addAddressUseCase;
  final LocationService _locationService;
  final GetAreasWithCitiesUseCase _getAreasWithCitiesUseCase;

  AddressCubit(
      this._getAreasWithCitiesUseCase,
      this._getSavedAddressesUseCase,
      this._addAddressUseCase,
      this._locationService,
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
    }
  }


  Future<void> _getAreasWithCities() async {
    final result = await _getAreasWithCitiesUseCase();

    switch (result) {
      case SuccessResponse<List<AreaEntity>>():
        final areas = result.data ?? [];

        debugPrint('========== AREAS LOADED ==========');
        debugPrint('Areas count: ${areas.length}');

        for (final area in areas) {
          debugPrint('AREA: ${area.name}');

          for (final city in area.cities) {
            debugPrint('   CITY: ${city.name}');
          }
        }

        debugPrint('==================================');

        emit(
          state.copyWith(
            areas: areas,
          ),
        );

      case ErrorResponse<List<AreaEntity>>():
        debugPrint(
          'Get areas error: ${result.errMessage}',
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
  // ============================================================
  // SELECT CITY
  // ============================================================

  void _selectCity(CityEntity city) {
    emit(
      state.copyWith(
        selectedCity: city,
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
}
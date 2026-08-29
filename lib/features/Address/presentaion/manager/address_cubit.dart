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
import '../../domain/use_cases/get_saved_address_useacse.dart';
import 'address_events.dart';
import 'address_state.dart';

@LazySingleton()
class AddressCubit extends Cubit<AddressState> {
  final GetSavedAddressesUseCase _getSavedAddressesUseCase;
  final AddAddressUseCase _addAddressUseCase;
  final LocationService _locationService;

  AddressCubit(
      this._getSavedAddressesUseCase,
      this._addAddressUseCase,
      this._locationService,
      ) : super(AddressState.initial());

  Future<void> doEvents(AddressEvent event) async {
    switch (event) {
      case GetSavedAddressesEvent():
        await _getSavedAddresses();

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

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // ============================================================
  // FIND AREA
  // ============================================================

  AreaEntity? _findMatchingArea(
      List<AreaEntity> areas,
      String? geocodedArea,
      ) {
    if (geocodedArea == null) return null;

    final normalizedGeocodedArea = _normalize(geocodedArea);

    for (final area in areas) {
      final areaName = area.name;

      if (areaName != null &&
          _normalize(areaName) == normalizedGeocodedArea) {
        return area;
      }
    }

    return null;
  }

  // ============================================================
  // FIND CITY
  // ============================================================

  CityEntity? _findMatchingCity(
      List<AreaEntity> areas,
      String? geocodedCity,
      ) {
    if (geocodedCity == null) return null;

    final normalizedGeocodedCity = _normalize(geocodedCity);

    for (final area in areas) {
      for (final city in area.cities ?? []) {
        final cityName = city.name;

        if (cityName != null &&
            _normalize(cityName) == normalizedGeocodedCity) {
          return city;
        }
      }
    }

    return null;
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
      debugPrint('City: ${locationDetails.city}');
      debugPrint('Area: ${locationDetails.area}');
      debugPrint('========================================');

      CityEntity? matchedCity;
      AreaEntity? matchedArea;

      String normalize(String? value) {
        if (value == null) return '';

        return value
            .toLowerCase()
            .replaceAll('-', ' ')
            .replaceAll('_', ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
      }

      final geocodedCity = normalize(locationDetails.city);
      final geocodedArea = normalize(locationDetails.area);

      // ============================================================
      // FIND CITY
      // ============================================================

      for (final area in state.areas) {
        for (final city in area.cities) {
          if (normalize(city.name) == geocodedCity) {
            matchedCity = city;
            break;
          }
        }

        if (matchedCity != null) {
          break;
        }
      }

      // ============================================================
      // FIND AREA
      // ============================================================

      if (matchedCity != null) {
        for (final area in state.areas) {
          final containsCity = area.cities.any(
                (city) => city.id == matchedCity!.id,
          );

          if (containsCity &&
              normalize(area.name) == geocodedArea) {
            matchedArea = area;
            break;
          }
        }
      }

      debugPrint('Matched city: ${matchedCity?.name}');
      debugPrint('Matched city ID: ${matchedCity?.id}');
      debugPrint('Matched area: ${matchedArea?.name}');
      debugPrint('Matched area ID: ${matchedArea?.id}');

      emit(
        state.copyWith(
          selectedLocation: location,
          selectedLocationDetails: locationDetails,
          selectedCity: matchedCity,
          selectedArea: matchedArea,
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
    final matchingAreas = state.areas
        .where(
          (area) => area.cities.any(
            (item) => item.id == city.id,
      ),
    )
        .toList();

    emit(
      state.copyWith(
        selectedCity: city,
        areas: matchingAreas,
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


  List<AreaEntity> get filteredAreas {
    final selectedCity = state.selectedCity;

    if (selectedCity == null) {
      return [];
    }

    return state.areas
        .where(
          (area) => area.cities.any(
            (city) => city.id == selectedCity.id,
      ),
    )
        .toList();
  }
}
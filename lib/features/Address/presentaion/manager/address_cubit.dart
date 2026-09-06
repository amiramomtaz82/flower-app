
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../../config/base_response/base_response.dart';
import '../../../../../config/resource/rsource.dart';
import '../../../../core/guest_browsing/guest_browsing_provider.dart';
import '../../../../core/location/location_service.dart';
import '../../domain/entities/add_address_entity.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/area_entity.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/use_cases/add_address_usecase.dart';
import '../../domain/use_cases/get_areas_with_cities_usecase.dart';
import '../../domain/use_cases/get_saved_address_useacse.dart';
import '../../domain/use_cases/set_default_address_usecase.dart';
import 'address_events.dart';
import 'address_state.dart';

@LazySingleton()
class AddressCubit extends Cubit<AddressState> {
  final GetSavedAddressesUseCase _getSavedAddressesUseCase;
  final AddAddressUseCase _addAddressUseCase;
  final LocationService _locationService;
  final GuestBrowsingProvider _guestBrowsingProvider;
  final SetDefaultAddressUseCase _setDefaultAddressUseCase;
  final GetAreasWithCitiesUseCase _getAreasWithCitiesUseCase;

  AddressCubit(
      this._getSavedAddressesUseCase,
      this._addAddressUseCase,
      this._locationService,
      this._setDefaultAddressUseCase,
      this._guestBrowsingProvider,
      this._getAreasWithCitiesUseCase,
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

      case SetDefaultAddressEvent():
        await _setDefaultAddress(event.addressId);

      case ResolveHomeAddressEvent():
        await _resolveHomeAddress();

      case GetAreasWithCitiesEvent():
        await _getAreasWithCities();

      case ResetAddAddressStateEvent():
        _resetAddAddressState();
    }
  }

  // ============================================================
  // GET SAVED ADDRESSES
  // ============================================================

  Future<void> _getSavedAddresses() async {
    // 1. Check if the user is a guest
    final isGuest = await _guestBrowsingProvider.isGuest();

    if (isGuest) {
      emit(
        state.copyWith(
          isGuest: true,
          addresses: const [],
          selectedAddress: null,
          getAddressesResource: Resource.initial(), // Do not leave in loading
        ),
      );
      return; // Exit before calling the usecase
    }

    // 2. User has an active session -> proceed with loading and fetching
    emit(
      state.copyWith(
        isGuest: false,
        getAddressesResource: Resource.loading(),
      ),
    );

    final result = await _getSavedAddressesUseCase();

    switch (result) {
      case SuccessResponse<List<AddressEntity>>():
        final addresses = result.data ?? [];

        emit(
          state.copyWith(
            isGuest: false,
            addresses: addresses,
            selectedAddress: addresses.isNotEmpty ? addresses.first : null,
            getAddressesResource: Resource.success(addresses),
          ),
        );

      case ErrorResponse<List<AddressEntity>>():
        emit(
          state.copyWith(
            isGuest: false,
            getAddressesResource: Resource.error(
              result.errMessage,
            ),
          ),
        );
    }
  }
  // ============================================================
  // GET AREAS WITH CITIES
  // ============================================================

  Future<void> _getAreasWithCities() async {
    final result = await _getAreasWithCitiesUseCase();

    switch (result) {
      case SuccessResponse<List<AreaEntity>>():
        final areas = result.data ?? [];
        emit(state.copyWith(areas: areas));

      case ErrorResponse<List<AreaEntity>>():
        debugPrint('Failed to load areas: ${result.errMessage ?? result.error}');
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
            // Reset form fields so subsequent visits start fresh
            selectedLocation: null,
            selectedLocationDetails: null,
            selectedCity: null,
            selectedArea: null,
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

  void _resetAddAddressState() {
    emit(
      state.copyWith(
        addAddressResource: Resource.initial(),
      ),
    );
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
      if (location != null) {
        await _selectLocation(location);
      }
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  // ============================================================
  // SELECT LOCATION & REVERSE GEOCODE
  // ============================================================

  String _normalize(String? value) {
    if (value == null) return '';
    return value
        .toLowerCase()
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> _selectLocation(LatLng location) async {
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

      if (locationDetails == null) {
        return;
      }

      final geocodedArea = _normalize(locationDetails.area);
      final geocodedCity = _normalize(locationDetails.city);

      AreaEntity? matchedArea;
      CityEntity? matchedCity;

      // 1. Find the parent Area first
      for (final area in state.areas) {
        if (_normalize(area.name) == geocodedArea) {
          matchedArea = area;
          break;
        }
      }

      // 2. Find the City inside the matched Area (or search all areas if area was inexact)
      if (matchedArea != null) {
        for (final city in matchedArea.cities) {
          if (_normalize(city.name) == geocodedCity) {
            matchedCity = city;
            break;
          }
        }
      } else {
        for (final area in state.areas) {
          for (final city in area.cities) {
            if (_normalize(city.name) == geocodedCity) {
              matchedArea = area;
              matchedCity = city;
              break;
            }
          }
          if (matchedCity != null) break;
        }
      }

      if (isClosed) return;

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
  // MANUAL AREA & CITY SELECTION
  // ============================================================

  void _selectArea(AreaEntity area) {
    // If the existing selectedCity is not in this new area, reset it
    final cityStillValid = area.cities.any(
          (city) => city.id == state.selectedCity?.id,
    );

    emit(
      state.copyWith(
        selectedArea: area,
        selectedCity: cityStillValid ? state.selectedCity : null,
      ),
    );
  }

  void _selectCity(CityEntity city) {
    emit(
      state.copyWith(
        selectedCity: city,
      ),
    );
  }

  // ============================================================
  // SET DEFAULT ADDRESS
  // ============================================================

  Future<void> _setDefaultAddress(String addressId) async {
    final previousAddresses = state.addresses;
    final previousSelected = state.selectedAddress;

    // 1. Optimistic update
    final updatedList = state.addresses.map((addr) {
      final isTarget = addr.id == addressId;
      return addr.copyWith(isDefault: isTarget);
    }).toList();

    final newDefault = updatedList.firstWhere(
          (a) => a.id == addressId,
      orElse: () => previousSelected ?? state.addresses.first,
    );

    emit(state.copyWith(
      addresses: updatedList,
      selectedAddress: newDefault,
    ));

    // 2. Call backend
    final result = await _setDefaultAddressUseCase(addressId);

    switch (result) {
      case SuccessResponse<AddressEntity>():
        final serverUpdatedAddress = result.data;

        if (serverUpdatedAddress == null) {
          emit(state.copyWith(
            addresses: previousAddresses,
            selectedAddress: previousSelected,
          ));
          return;
        }

        final confirmedList = state.addresses.map((addr) {
          if (addr.id == serverUpdatedAddress.id) {
            return serverUpdatedAddress;
          }
          return addr.copyWith(isDefault: false);
        }).toList();

        emit(state.copyWith(
          addresses: confirmedList,
          selectedAddress: serverUpdatedAddress,
        ));

      case ErrorResponse<AddressEntity>():
        emit(state.copyWith(
          addresses: previousAddresses,
          selectedAddress: previousSelected,
        ));
    }
  }

  // ============================================================
  // RESOLVE HOME ADDRESS
  // ============================================================

  Future<void> _resolveHomeAddress() async {
    if (isClosed) return;

    final isGuest = await _guestBrowsingProvider.isGuest();

    // 1. If logged in and has saved addresses, pick the default or nearest
    if (!isGuest && state.addresses.isNotEmpty) {
      final defaultAddress = state.addresses.firstWhere(
            (a) => a.isDefault == true,
        orElse: () => state.addresses.first,
      );
      emit(state.copyWith(isGuest: false, selectedAddress: defaultAddress));
      return;
    }

    // 2. If guest or 0 addresses, try GPS
    final currentCoordinates = await _locationService.getCurrentLocation();
    if (isClosed) return;

    if (currentCoordinates != null) {
      final locationDetails = await _locationService.reverseGeocode(
        lat: currentCoordinates.latitude,
        lng: currentCoordinates.longitude,
      );
      if (isClosed) return;

      emit(state.copyWith(
        isGuest: isGuest,
        selectedLocation: currentCoordinates,
        selectedLocationDetails: locationDetails,
      ));
    } else {
      // GPS rejected, disabled, or unavailable -> remain in standard guest/empty state
      emit(state.copyWith(isGuest: isGuest));
    }
  }
  void resetToGuest() {
    emit(
      state.copyWith(
        isGuest: true,
        addresses: const [],
        selectedAddress: null,
        getAddressesResource: Resource.initial(),
      ),
    );
  }
}
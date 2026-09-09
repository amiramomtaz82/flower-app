
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
import '../../domain/entities/geocoded_location_result.dart';
import '../../domain/use_cases/add_address_usecase.dart';
import '../../domain/use_cases/get_areas_with_cities_usecase.dart';
import '../../domain/use_cases/get_current_location_usecase.dart';
import '../../domain/use_cases/get_saved_address_useacse.dart';
import '../../domain/use_cases/reslove_location_with _areas_usecase.dart';
import '../../domain/use_cases/set_default_address_usecase.dart';
import 'address_events.dart';
import 'address_state.dart';

@LazySingleton()
class AddressCubit extends Cubit<AddressState> {
  final GetSavedAddressesUseCase _getSavedAddressesUseCase;
  final AddAddressUseCase _addAddressUseCase;
  final GuestBrowsingProvider _guestBrowsingProvider;
  final SetDefaultAddressUseCase _setDefaultAddressUseCase;
  final GetAreasWithCitiesUseCase _getAreasWithCitiesUseCase;
  final GetCurrentLocationUseCase _getCurrentLocationUseCase;
  final ResolveLocationWithAreasUseCase _resolveLocationWithAreasUseCase;
  final LocationService _locationService;

  AddressCubit(
      this._getSavedAddressesUseCase,
      this._addAddressUseCase,
      this._setDefaultAddressUseCase,
      this._guestBrowsingProvider,
      this._getAreasWithCitiesUseCase,
      this._getCurrentLocationUseCase,
      this._resolveLocationWithAreasUseCase,
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
    final isGuest = await _guestBrowsingProvider.isGuest();

    if (isGuest) {
      emit(
        state.copyWith(
          isGuest: true,
          addresses: const [],
          clearSelectedAddress: true,
          getAddressesResource: Resource.initial(),
        ),
      );
      return;
    }

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
        final defaultAddress = addresses.firstWhere(
              (a) => a.isDefault == true,
          orElse: () => addresses.isNotEmpty ? addresses.first : const AddressEntity(),
        );

        emit(
          state.copyWith(
            isGuest: false,
            addresses: addresses,
            selectedAddress: addresses.isNotEmpty ? defaultAddress : null,
            getAddressesResource: Resource.success(addresses),
          ),
        );

      case ErrorResponse<List<AddressEntity>>():
        emit(
          state.copyWith(
            isGuest: false,
            getAddressesResource: Resource.error(result.errMessage),
          ),
        );
    }
  }

  // ============================================================
  // GET AREAS WITH CITIES
  // ============================================================

  Future<void> _getAreasWithCities() async {
    emit(
      state.copyWith(
        areasResource: Resource.loading(),
      ),
    );

    final result = await _getAreasWithCitiesUseCase();

    switch (result) {
      case SuccessResponse<List<AreaEntity>>():
        final areas = result.data ?? [];
        emit(
          state.copyWith(
            areas: areas,
            areasResource: Resource.success(areas),
          ),
        );

      case ErrorResponse<List<AreaEntity>>():
        emit(
          state.copyWith(
            areasResource: Resource.error(result.errMessage),
          ),
        );
    }
  }

  // ============================================================
  // ADD ADDRESS
  // ============================================================

  Future<void> _addAddress(AddAddressEntity address) async {
    emit(state.copyWith(addAddressResource: Resource.loading()));

    final result = await _addAddressUseCase(address);

    switch (result) {
      case SuccessResponse<AddressEntity>():
        final newAddress = result.data;
        if (newAddress == null) {
          emit(
            state.copyWith(
              addAddressResource: Resource.error('Address was not created'),
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            addresses: [...state.addresses, newAddress],
            selectedAddress: newAddress,
            addAddressResource: Resource.success(newAddress),
            selectedLocation: null,
            selectedLocationDetails: null,
            selectedCity: null,
            selectedArea: null,
          ),
        );

      case ErrorResponse<AddressEntity>():
        emit(
          state.copyWith(
            addAddressResource: Resource.error(result.errMessage),
          ),
        );
    }
  }

  void _resetAddAddressState() {
    emit(state.copyWith(addAddressResource: Resource.initial()));
  }

  // ============================================================
  // SELECT SAVED ADDRESS
  // ============================================================

  void _selectAddress(AddressEntity address) {
    emit(state.copyWith(selectedAddress: address));
  }

  // ============================================================
  // GET CURRENT LOCATION
  // ============================================================

  Future<void> _getCurrentLocation() async {
    final result = await _getCurrentLocationUseCase();

    if (result is SuccessResponse<LatLng> && result.data != null) {
      await _selectLocation(result.data!);
    }
  }

  // ============================================================
  // SELECT LOCATION & REVERSE GEOCODE
  // ============================================================

  Future<void> _selectLocation(LatLng location) async {
    emit(
      state.copyWith(
        selectedLocation: location,
        locationDetailsResource: Resource.loading(),
      ),
    );

    final result = await _resolveLocationWithAreasUseCase(
      location: location,
      areas: state.areas,
    );

    if (isClosed) return;

    switch (result) {
      case SuccessResponse<GeocodedLocationResult>():
        final data = result.data;
        emit(
          state.copyWith(
            selectedLocation: data.location,
            selectedLocationDetails: data.details,
            selectedArea: data.matchedArea,
            selectedCity: data.matchedCity,
            locationDetailsResource: Resource.success(data),
          ),
        );

      case ErrorResponse<GeocodedLocationResult>():
        emit(
          state.copyWith(
            locationDetailsResource: Resource.error(result.errMessage),
          ),
        );
    }
  }

  // ============================================================
  // MANUAL AREA & CITY SELECTION
  // ============================================================

  void _selectArea(AreaEntity area) {
    final cityStillValid = area.cities.any(
          (city) => city.id == state.selectedCity?.id,
    );

    emit(
      state.copyWith(
        selectedArea: area,
        selectedCity: cityStillValid ? state.selectedCity : null,
        clearSelectedCity: !cityStillValid,
      ),
    );
  }

  void _selectCity(CityEntity city) {
    emit(state.copyWith(selectedCity: city));
  }

  // ============================================================
  // SET DEFAULT ADDRESS
  // ============================================================

  Future<void> _setDefaultAddress(String addressId) async {
    emit(
      state.copyWith(
        setDefaultAddressResource: Resource.loading(),
      ),
    );

    final result = await _setDefaultAddressUseCase(addressId);

    switch (result) {
      case SuccessResponse<AddressEntity>():
        final serverUpdatedAddress = result.data;

        final updatedList = state.addresses.map((addr) {
          if (addr.id == serverUpdatedAddress.id) {
            return serverUpdatedAddress;
          }
          return addr.copyWith(isDefault: false);
        }).toList();

        emit(
          state.copyWith(
            addresses: updatedList,
            selectedAddress: serverUpdatedAddress,
            setDefaultAddressResource: Resource.success(serverUpdatedAddress),
          ),
        );

      case ErrorResponse<AddressEntity>():
        emit(
          state.copyWith(
            setDefaultAddressResource: Resource.error(result.errMessage),
          ),
        );
    }
  }

  // ============================================================
  // RESOLVE HOME ADDRESS
  // ============================================================

  Future<void> _resolveHomeAddress() async {
    if (isClosed) return;

    final isGuest = await _guestBrowsingProvider.isGuest();

    // 1. If guest or user has no saved addresses, do nothing (UI will show "Add Address")
    if (isGuest || state.addresses.isEmpty) {
      emit(state.copyWith(isGuest: isGuest));
      return;
    }

    // 2. Locate the existing fallback default address
    final defaultAddress = state.addresses.firstWhere(
          (a) => a.isDefault == true,
      orElse: () => state.addresses.first,
    );

    // 3. Emit loading while checking GPS proximity
    emit(
      state.copyWith(
        setDefaultAddressResource: Resource.loading(),
      ),
    );

    // 4. Try to get current position passively without requesting permissions
    final locResult = await _getCurrentLocationUseCase();
    if (isClosed) return;

    if (locResult is SuccessResponse<LatLng> && locResult.data != null) {
      final currentPosition = locResult.data!;

      // 5. Look for the closest saved address within threshold
      final closestAddress = _locationService.getClosestAddress(
        state.addresses,
        currentPosition,
      );

      if (closestAddress != null && closestAddress.id != null) {
        // If it's already the default address, simply select it without an API call
        if (closestAddress.isDefault == true) {
          emit(
            state.copyWith(
              selectedAddress: closestAddress,
              setDefaultAddressResource: Resource.success(closestAddress),
            ),
          );
          return;
        }

        // If it is not the default, update it on the server
        await _setDefaultAddress(closestAddress.id!);
        return;
      }
    }

    // 6. Fallback: GPS not obtained, out of range, or no coordinates -> retain current default
    emit(
      state.copyWith(
        selectedAddress: defaultAddress,
        setDefaultAddressResource: Resource.success(defaultAddress),
      ),
    );
  }

  // In AddressCubit
  void resetToGuest() {
    emit(
      state.copyWith(
        isGuest: true,
        addresses: const [],
        clearSelectedAddress: true, // <-- Clears the address cleanly
        getAddressesResource: Resource.initial(),
      ),
    );
  }
}
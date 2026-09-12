
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
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
import '../../domain/use_cases/add_address_use_case.dart';
import '../../domain/use_cases/delete_address_use_case.dart';
import '../../domain/use_cases/get_areas_with_cities_use_case.dart';
import '../../domain/use_cases/get_current_location_use_case.dart';
import '../../domain/use_cases/get_saved_address_use_case.dart';
import '../../domain/use_cases/resolve_location_with_areas_use_case.dart';
import '../../domain/use_cases/set_default_address_use_case.dart';
import '../../domain/use_cases/update_address_use_case.dart';
import 'address_events.dart';
import 'address_state.dart';

@LazySingleton()
class AddressCubit extends Cubit<AddressState> {
  final GetSavedAddressesUseCase _getSavedAddressesUseCase;
  final AddAddressUseCase _addAddressUseCase;
  final UpdateAddressUseCase _updateAddressUseCase;
  final DeleteAddressUseCase _deleteAddressUseCase;
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
      this._updateAddressUseCase,
      this._deleteAddressUseCase,
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
      case UpdateAddressEvent(:final id, :final entity):
        _updateAddress(id: id, address: entity);
      case DeleteAddressEvent(:final id):
        _deleteAddress(id);
    }
  }
// ==================== Update Address ====================
  Future<void> _updateAddress({
    required String id,
    required AddressEntity address,
  }) async {
    emit(state.copyWith(updateAddressResource: Resource.loading()));

    final response = await _updateAddressUseCase(id: id, address: address);

    switch (response) {
      case SuccessResponse<AddressEntity>(:final data):
        emit(state.copyWith(updateAddressResource: Resource.success(data)));
        await _getSavedAddresses();
      case ErrorResponse<AddressEntity>():
        emit(
          state.copyWith(
            updateAddressResource: Resource.error(response.errMessage),
          ),
        );
    }
  }

  // ==================== Delete Address & Reassign Default ====================
  Future<void> _deleteAddress(String id) async {
    emit(state.copyWith(deleteAddressResource: Resource.loading()));

    final targetAddress = state.addresses.firstWhere(
          (a) => a.id == id,
      orElse: () => const AddressEntity(),
    );
    final wasDefault = targetAddress.isDefault == true;

    final response = await _deleteAddressUseCase(id);

    switch (response) {
      case SuccessResponse<void>():
        emit(state.copyWith(deleteAddressResource: Resource.success(null)));

        await _getSavedAddresses();

        // Default reassignment: if the deleted address was default, pick next available
        if (wasDefault && state.addresses.isNotEmpty) {
          final nextDefault = state.addresses.firstWhere(
                (a) => a.isServiceable == true,
            orElse: () => state.addresses.first,
          );
          if (nextDefault.id != null) {
            await _setDefaultAddressUseCase(nextDefault.id!);
            await _getSavedAddresses();
          }
        }
      case ErrorResponse<void>():
        emit(
          state.copyWith(
            deleteAddressResource: Resource.error(response.errMessage),
          ),
        );
    }
  }

//
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

        // Run proximity GPS check if user has saved addresses
        if (addresses.isNotEmpty) {
          await _resolveHomeAddress();
        }

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

  // ============================================================
// RESOLVE HOME ADDRESS
// ============================================================

  Future<void> _resolveHomeAddress() async {
    if (isClosed) return;

    final isGuest = await _guestBrowsingProvider.isGuest();
    if (isGuest || state.addresses.isEmpty) {
      emit(
        state.copyWith(
          isGuest: isGuest,
          clearSelectedAddress: isGuest,
        ),
      );
      return;
    }

    // 1. Establish the default fallback address
    final defaultAddress = state.addresses.firstWhere(
          (a) => a.isDefault == true && a.isServiceable == true,
      orElse: () => state.addresses.firstWhere(
            (a) => a.isDefault == true,
        orElse: () => state.addresses.first,
      ),
    );

    // 2. Fetch current GPS passively (requestIfDenied: false prevents dialog prompts)
    final locResult = await _getCurrentLocationUseCase(requestIfDenied: false);
    if (isClosed) return;

    if (locResult is SuccessResponse<LatLng> && locResult.data != null) {
      final currentPosition = locResult.data!;

      // 3. Filter to serviceable addresses
      final serviceableAddresses = state.addresses
          .where((a) => a.isServiceable == true)
          .toList();

      // 4. Look for closest address within 500m
      final closestAddress = _locationService.getClosestAddress(
        serviceableAddresses.isNotEmpty ? serviceableAddresses : state.addresses,
        currentPosition,
        maxRangeMeters: 500.0,
      );

      if (closestAddress != null) {
        emit(state.copyWith(selectedAddress: closestAddress));
        return;
      }
    }

    // 5. GPS off, denied, failed, or > 500m -> fallback to default address
    emit(state.copyWith(selectedAddress: defaultAddress));
  }
}
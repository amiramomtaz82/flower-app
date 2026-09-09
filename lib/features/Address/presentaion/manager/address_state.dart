// lib/features/Address/presentaion/manager/address_state.dart
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../../config/resource/rsource.dart';
import '../../../../core/location/location_model.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/area_entity.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/entities/geocoded_location_result.dart';

class AddressState extends Equatable {
  final List<AddressEntity> addresses;
  final AddressEntity? selectedAddress;
  final Resource<List<AddressEntity>> getAddressesResource;
  final Resource<AddressEntity> addAddressResource;
  final Resource<AddressEntity> setDefaultAddressResource;
  final Resource<List<AreaEntity>> areasResource;
  final Resource<GeocodedLocationResult> locationDetailsResource;
  final List<AreaEntity> areas;
  final LatLng? selectedLocation;
  final LocationModel? selectedLocationDetails;
  final CityEntity? selectedCity;
  final AreaEntity? selectedArea;
  final bool? isGuest;

  const AddressState({
    required this.addresses,
    this.selectedAddress,
    required this.getAddressesResource,
    required this.addAddressResource,
    required this.setDefaultAddressResource,
    required this.areasResource,
    required this.locationDetailsResource,
    required this.areas,
    this.selectedLocation,
    this.selectedLocationDetails,
    this.selectedCity,
    this.selectedArea,
    this.isGuest,
  });

  factory AddressState.initial() => AddressState(
    addresses: const [],
    selectedAddress: null,
    getAddressesResource: Resource.initial(),
    addAddressResource: Resource.initial(),
    setDefaultAddressResource: Resource.initial(),
    areasResource: Resource.initial(),
    locationDetailsResource: Resource.initial(),
    areas: const [],
    isGuest: null,
  );

  // ============================================================
  // GETTERS FOR UI SELECTION SAFETY
  // ============================================================

  /// Returns [selectedArea] only if it exists in the active [areas] list,
  /// preventing dropdown assertion crashes when options change.
  AreaEntity? get validSelectedArea {
    if (selectedArea == null) return null;
    final exists = areas.any((a) => a.id == selectedArea!.id);
    return exists ? selectedArea : null;
  }

  /// List of available cities derived from the currently validated area.
  List<CityEntity> get availableCities {
    return validSelectedArea?.cities ?? const [];
  }

  /// Returns [selectedCity] only if it exists in the [availableCities] list
  /// of the selected area.
  CityEntity? get validSelectedCity {
    if (selectedCity == null) return null;
    final exists = availableCities.any((c) => c.id == selectedCity!.id);
    return exists ? selectedCity : null;
  }

  // In AddressState (lib/features/Address/presentaion/manager/address_state.dart)
  AddressState copyWith({
    List<AddressEntity>? addresses,
    AddressEntity? selectedAddress,
    bool clearSelectedAddress = false, // <-- Add this flag
    Resource<List<AddressEntity>>? getAddressesResource,
    Resource<AddressEntity>? addAddressResource,
    Resource<AddressEntity>? setDefaultAddressResource,
    Resource<List<AreaEntity>>? areasResource,
    Resource<GeocodedLocationResult>? locationDetailsResource,
    List<AreaEntity>? areas,
    LatLng? selectedLocation,
    LocationModel? selectedLocationDetails,
    CityEntity? selectedCity,
    bool clearSelectedCity = false,
    AreaEntity? selectedArea,
    bool? isGuest,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      selectedAddress: clearSelectedAddress
          ? null
          : (selectedAddress ?? this.selectedAddress), // <-- Use flag here
      getAddressesResource: getAddressesResource ?? this.getAddressesResource,
      addAddressResource: addAddressResource ?? this.addAddressResource,
      setDefaultAddressResource:
      setDefaultAddressResource ?? this.setDefaultAddressResource,
      areasResource: areasResource ?? this.areasResource,
      locationDetailsResource:
      locationDetailsResource ?? this.locationDetailsResource,
      areas: areas ?? this.areas,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      selectedLocationDetails:
      selectedLocationDetails ?? this.selectedLocationDetails,
      selectedCity:
      clearSelectedCity ? null : (selectedCity ?? this.selectedCity),
      selectedArea: selectedArea ?? this.selectedArea,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  @override
  List<Object?> get props => [
    addresses,
    selectedAddress,
    getAddressesResource,
    addAddressResource,
    setDefaultAddressResource,
    areasResource,
    locationDetailsResource,
    areas,
    selectedLocation,
    selectedLocationDetails,
    selectedCity,
    selectedArea,
    isGuest,
  ];
}
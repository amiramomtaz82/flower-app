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
  final Resource<GeocodedLocationResult> locationDetailsResource; // Added
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
    required this.locationDetailsResource, // Added
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
    locationDetailsResource: Resource.initial(), // Added
    areas: const [],
    isGuest: null,
  );

  AddressState copyWith({
    List<AddressEntity>? addresses,
    AddressEntity? selectedAddress,
    Resource<List<AddressEntity>>? getAddressesResource,
    Resource<AddressEntity>? addAddressResource,
    Resource<AddressEntity>? setDefaultAddressResource,
    Resource<List<AreaEntity>>? areasResource,
    Resource<GeocodedLocationResult>? locationDetailsResource,
    List<AreaEntity>? areas,
    LatLng? selectedLocation,
    LocationModel? selectedLocationDetails,
    CityEntity? selectedCity,
    bool clearSelectedCity = false, // Added flag
    AreaEntity? selectedArea,
    bool? isGuest,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      selectedAddress: selectedAddress ?? this.selectedAddress,
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
      selectedCity: clearSelectedCity ? null : (selectedCity ?? this.selectedCity),
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
    locationDetailsResource, // Added
    areas,
    selectedLocation,
    selectedLocationDetails,
    selectedCity,
    selectedArea,
    isGuest,
  ];
}
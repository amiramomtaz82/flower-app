import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../../config/resource/rsource.dart';
import '../../../../core/location/location_model.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/area_entity.dart';
import '../../domain/entities/city_entity.dart';

class AddressState extends Equatable {
  final List<AddressEntity> addresses;
  final AddressEntity? selectedAddress;
  final Resource<List<AddressEntity>> getAddressesResource;
  final Resource<AddressEntity> addAddressResource;
  final LatLng? selectedLocation;
  final LocationModel? selectedLocationDetails;
  final List<AreaEntity> areas;
  final CityEntity? selectedCity;
  final AreaEntity? selectedArea;
  final bool? isGuest;

  const AddressState({
    required this.addresses,
    this.selectedAddress,
    required this.getAddressesResource,
    required this.addAddressResource,
    this.selectedLocation,
    this.selectedLocationDetails,
    required this.areas,
    this.selectedCity,
    this.selectedArea,
    this.isGuest ,
  });

  factory AddressState.initial() => AddressState(
    addresses: const [],
    selectedAddress: null,
    getAddressesResource: Resource.initial(),
    addAddressResource: Resource.initial(),
    areas: const [],
    isGuest: null,
  );

  AddressState copyWith({
    List<AddressEntity>? addresses,
    AddressEntity? selectedAddress,
    Resource<List<AddressEntity>>? getAddressesResource,
    Resource<AddressEntity>? addAddressResource,
    LatLng? selectedLocation,
    LocationModel? selectedLocationDetails,
    List<AreaEntity>? areas,
    CityEntity? selectedCity,
    AreaEntity? selectedArea,
    bool? isGuest, // <-- Added parameter
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      getAddressesResource: getAddressesResource ?? this.getAddressesResource,
      addAddressResource: addAddressResource ?? this.addAddressResource,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      selectedLocationDetails:
      selectedLocationDetails ?? this.selectedLocationDetails,
      areas: areas ?? this.areas,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedArea: selectedArea ?? this.selectedArea,
      isGuest: isGuest ?? this.isGuest, // <-- Assigned
    );
  }

  @override
  List<Object?> get props => [
    addresses,
    selectedAddress,
    getAddressesResource,
    addAddressResource,
    selectedLocation,
    selectedLocationDetails,
    areas,
    selectedCity,
    selectedArea,
    isGuest, // <-- Added to Equatable props
  ];
}
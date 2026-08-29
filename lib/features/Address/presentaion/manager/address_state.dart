import 'package:equatable/equatable.dart';
import 'package:flower_app/features/Address/domain/entities/address_entity.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../config/resource/rsource.dart';
import '../../../../core/location/location_model.dart';
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
  List<CityEntity> get cities {
    return areas
        .expand((area) => area.cities)
        .toSet()
        .toList();
  }
  final CityEntity? selectedCity;
  final AreaEntity? selectedArea;

  AddressState({
    this.addresses = const [],
    this.selectedAddress,
    this.selectedLocationDetails,
    this.selectedLocation,
    this.areas = const [],
    this.selectedCity,
    this.selectedArea,
    Resource<List<AddressEntity>>? getAddressesResource,
    Resource<AddressEntity>? addAddressResource,
  })  : getAddressesResource =
      getAddressesResource ?? Resource.initial(),
        addAddressResource =
            addAddressResource ?? Resource.initial();

  factory AddressState.initial() {
    return AddressState(
      getAddressesResource: Resource.initial(),
      addAddressResource: Resource.initial(),
    );
  }

  AddressState copyWith({
    List<AddressEntity>? addresses,
    AddressEntity? selectedAddress,
    Resource<List<AddressEntity>>? getAddressesResource,
    Resource<AddressEntity>? addAddressResource,
    LatLng? selectedLocation,
    LocationModel? selectedLocationDetails,
    CityEntity? selectedCity,
    AreaEntity? selectedArea,
    List<AreaEntity>? areas,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      selectedAddress: selectedAddress ?? this.selectedAddress,

      getAddressesResource:
      getAddressesResource ?? this.getAddressesResource,

      addAddressResource:
      addAddressResource ?? this.addAddressResource,

      selectedLocation:
      selectedLocation ?? this.selectedLocation,

      selectedLocationDetails:
      selectedLocationDetails ?? this.selectedLocationDetails,

      selectedCity:
      selectedCity ?? this.selectedCity,

      selectedArea:
      selectedArea ?? this.selectedArea,

      areas:
      areas ?? this.areas,
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
  ];
}
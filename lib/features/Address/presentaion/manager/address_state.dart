import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../config/resource/rsource.dart';
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

  /// Cities, each carrying its nested areas.
  final List<CityEntity> cities;
  final CityEntity? selectedCity;
  final AreaEntity? selectedArea;

  /// The address currently being viewed/edited on the Details & Edit screens.
  final AddressEntity? addressDetails;
  final Resource<AddressEntity> getAddressByIdResource;
  final Resource<AddressEntity> updateAddressResource;

  AddressState({
    this.addresses = const [],
    this.selectedAddress,
    this.selectedLocationDetails,
    this.selectedLocation,
    this.cities = const [],
    this.selectedCity,
    this.selectedArea,
    this.addressDetails,
    Resource<List<AddressEntity>>? getAddressesResource,
    Resource<AddressEntity>? addAddressResource,
    Resource<AddressEntity>? getAddressByIdResource,
    Resource<AddressEntity>? updateAddressResource,
  })  : getAddressesResource =
      getAddressesResource ?? Resource.initial(),
        addAddressResource =
            addAddressResource ?? Resource.initial(),
        getAddressByIdResource =
            getAddressByIdResource ?? Resource.initial(),
        updateAddressResource =
            updateAddressResource ?? Resource.initial();

  factory AddressState.initial() {
    return AddressState(
      getAddressesResource: Resource.initial(),
      addAddressResource: Resource.initial(),
      getAddressByIdResource: Resource.initial(),
      updateAddressResource: Resource.initial(),
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
    List<CityEntity>? cities,
    AddressEntity? addressDetails,
    Resource<AddressEntity>? getAddressByIdResource,
    Resource<AddressEntity>? updateAddressResource,
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

      cities:
      cities ?? this.cities,

      addressDetails:
      addressDetails ?? this.addressDetails,

      getAddressByIdResource:
      getAddressByIdResource ?? this.getAddressByIdResource,

      updateAddressResource:
      updateAddressResource ?? this.updateAddressResource,
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
    cities,
    selectedCity,
    selectedArea,
    addressDetails,
    getAddressByIdResource,
    updateAddressResource,
  ];
}

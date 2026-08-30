import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/add_address_entity.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/area_entity.dart';
import '../../domain/entities/city_entity.dart';

sealed class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

class GetSavedAddressesEvent extends AddressEvent {
  const GetSavedAddressesEvent();
}

class AddAddressEvent extends AddressEvent {
  final AddAddressEntity address;

  const AddAddressEvent(this.address);

  @override
  List<Object?> get props => [address];
}

class SelectAddressEvent extends AddressEvent {
  final AddressEntity address;

  const SelectAddressEvent(this.address);

  @override
  List<Object?> get props => [address];
}
class GetCurrentLocationEvent extends AddressEvent {
  const GetCurrentLocationEvent();
}

class SelectLocationEvent extends AddressEvent{
  final LatLng location;
  SelectLocationEvent(this.location);
}
class SelectCityEvent extends AddressEvent {
CityEntity city;

  SelectCityEvent(this.city);
}

class SelectAreaEvent extends AddressEvent {
  AreaEntity area;

  SelectAreaEvent(this.area);
}

class GetAreasWithCitiesEvent extends AddressEvent {
  const GetAreasWithCitiesEvent();
}
class InitializeAddressEvent extends AddressEvent {
  const InitializeAddressEvent();
}

class SetDefaultAddressEvent extends AddressEvent {
  final String addressId;

  const SetDefaultAddressEvent(this.addressId);

  @override
  List<Object?> get props => [addressId];
}

class InitializeHomeAddressEvent extends AddressEvent {
  const InitializeHomeAddressEvent();
}
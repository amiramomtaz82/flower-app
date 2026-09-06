import 'package:equatable/equatable.dart';

import 'city_entity.dart';

class AreaEntity extends Equatable {
  final String id;
  final String name;
  final List<CityEntity> cities;

  const AreaEntity({
    required this.id,
    required this.name,
    required this.cities,
  });

  @override
  List<Object?> get props => [id, name, cities];
}
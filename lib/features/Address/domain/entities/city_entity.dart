import 'package:equatable/equatable.dart';

import 'area_entity.dart';

class CityEntity extends Equatable {
  final String id;
  final String name;
  final List<AreaEntity> areas;

  const CityEntity({
    required this.id,
    required this.name,
    this.areas = const [],
  });

  @override
  List<Object?> get props => [id, name, areas];
}

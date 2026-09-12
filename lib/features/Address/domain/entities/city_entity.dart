import 'package:equatable/equatable.dart';

class CityEntity extends Equatable {
  final String id;
  final String name;

  const CityEntity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
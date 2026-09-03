import 'package:equatable/equatable.dart';

class AreaEntity extends Equatable {
  final String id;
  final String name;

  const AreaEntity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}

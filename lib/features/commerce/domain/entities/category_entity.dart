import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  const CategoryEntity({required this.id, required this.name, required this.icon});

  final String id;
  final String name;
  final String icon;

  @override
  List<Object?> get props => [id, name, icon];
}

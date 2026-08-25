import 'package:equatable/equatable.dart';

import 'home_section_type.dart';

class HomeSectionEntity extends Equatable {
  const HomeSectionEntity({
    required this.id,
    required this.type,
    required this.index,
    required this.isActive,
    this.title,
    this.occasionId,
    this.categoryId,
  });

  final String id;
  final HomeSectionType type;
  final int index;
  final bool isActive;
  final String? title;
  final String? occasionId;
  final String? categoryId;

  @override
  List<Object?> get props => [
    id,
    type,
    index,
    isActive,
    title,
    occasionId,
    categoryId,
  ];
}

import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/category_entity.dart';

part 'category_dto.g.dart';

@JsonSerializable()
class CategoryDTO {
  final String id;
  final String name;
  final String icon;

  const CategoryDTO({required this.id, required this.name, required this.icon});

  factory CategoryDTO.fromJson(Map<String, dynamic> json) =>
      _$CategoryDTOFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryDTOToJson(this);

  CategoryEntity toEntity() => CategoryEntity(id: id, name: name, icon: icon);
}

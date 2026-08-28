import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/home_section_entity.dart';
import '../../domain/entities/home_section_type.dart';

part 'home_section_dto.g.dart';

@JsonEnum()
enum HomeSectionTypeDto {
  @JsonValue('Categories')
  categories,
  @JsonValue('Occasions')
  occasions,
  @JsonValue('BestSeller')
  bestSeller,
  @JsonValue('ProductsCarousel')
  productsCarousel,
  @JsonValue('unknown')
  unknown,
}

@JsonSerializable()
class HomeSectionDTO {
  final String id;
  @JsonKey(unknownEnumValue: HomeSectionTypeDto.unknown)
  final HomeSectionTypeDto type;
  final int index;
  final bool isActive;
  final String? title;
  final String? occasionId;
  final String? categoryId;

  const HomeSectionDTO({
    required this.id,
    required this.type,
    required this.index,
    required this.isActive,
    this.title,
    this.occasionId,
    this.categoryId,
  });

  factory HomeSectionDTO.fromJson(Map<String, dynamic> json) =>
      _$HomeSectionDTOFromJson(json);

  Map<String, dynamic> toJson() => _$HomeSectionDTOToJson(this);

  HomeSectionEntity toEntity() => HomeSectionEntity(
    id: id,
    type: switch (type) {
      HomeSectionTypeDto.categories => HomeSectionType.categories,
      HomeSectionTypeDto.occasions => HomeSectionType.occasions,
      HomeSectionTypeDto.bestSeller => HomeSectionType.bestSeller,
      HomeSectionTypeDto.productsCarousel => HomeSectionType.productsCarousel,
      HomeSectionTypeDto.unknown => HomeSectionType.unknown,
    },
    index: index,
    isActive: isActive,
    title: title,
    occasionId: occasionId,
    categoryId: categoryId,
  );
}

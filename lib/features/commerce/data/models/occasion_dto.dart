import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/occasion_entity.dart';

part 'occasion_dto.g.dart';

@JsonSerializable()
class OccasionDTO {
  final String id;
  final String name;
  final String imageUrl;

  const OccasionDTO({required this.id, required this.name, required this.imageUrl});

  factory OccasionDTO.fromJson(Map<String, dynamic> json) =>
      _$OccasionDTOFromJson(json);

  Map<String, dynamic> toJson() => _$OccasionDTOToJson(this);

  OccasionEntity toEntity() =>
      OccasionEntity(id: id, name: name, imageUrl: imageUrl);
}

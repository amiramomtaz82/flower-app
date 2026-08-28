import 'package:json_annotation/json_annotation.dart';

import 'home_section_dto.dart';

part 'home_sections_response_model.g.dart';

@JsonSerializable()
class HomeSectionsResponseModel {
  final List<HomeSectionDTO> data;

  const HomeSectionsResponseModel({required this.data});

  factory HomeSectionsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$HomeSectionsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$HomeSectionsResponseModelToJson(this);
}

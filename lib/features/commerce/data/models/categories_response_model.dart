import 'package:json_annotation/json_annotation.dart';

import 'category_dto.dart';

part 'categories_response_model.g.dart';

@JsonSerializable()
class CategoriesResponseModel {
  final List<CategoryDTO> data;

  const CategoriesResponseModel({required this.data});

  factory CategoriesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CategoriesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoriesResponseModelToJson(this);
}

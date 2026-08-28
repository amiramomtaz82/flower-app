import 'package:json_annotation/json_annotation.dart';

import 'product_dto.dart';

part 'products_by_category_response_model.g.dart';

@JsonSerializable()
class ProductsByCategoryResponseModel {
  final List<ProductDTO> data;

  const ProductsByCategoryResponseModel({required this.data});

  factory ProductsByCategoryResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ProductsByCategoryResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductsByCategoryResponseModelToJson(this);
}

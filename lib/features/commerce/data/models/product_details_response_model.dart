import 'package:json_annotation/json_annotation.dart';

import 'product_details_dto.dart';

part 'product_details_response_model.g.dart';

@JsonSerializable()
class ProductDetailsResponseModel {
  final ProductDetailsDTO data;

  const ProductDetailsResponseModel({required this.data});

  factory ProductDetailsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ProductDetailsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductDetailsResponseModelToJson(this);
}

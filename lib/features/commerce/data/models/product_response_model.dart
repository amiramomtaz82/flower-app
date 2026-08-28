import 'package:json_annotation/json_annotation.dart';

import 'product_dto.dart';

part 'product_response_model.g.dart';

@JsonSerializable()
class ProductResponseModel {
  final ProductDTO data;

  const ProductResponseModel({required this.data});

  factory ProductResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ProductResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductResponseModelToJson(this);
}

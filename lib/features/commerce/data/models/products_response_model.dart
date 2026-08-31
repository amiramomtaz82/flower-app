import 'package:json_annotation/json_annotation.dart';

import 'products_data_model.dart';

part 'products_response_model.g.dart';

@JsonSerializable()
class ProductsResponseModel {
  @JsonKey(name: 'value')
  final ProductsDataModel data;

  const ProductsResponseModel({required this.data});

  factory ProductsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ProductsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductsResponseModelToJson(this);
}

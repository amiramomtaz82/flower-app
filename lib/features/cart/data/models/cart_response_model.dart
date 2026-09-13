import 'package:json_annotation/json_annotation.dart';

import 'cart_dto.dart';

part 'cart_response_model.g.dart';

@JsonSerializable()
class CartResponseModel {
  final bool? success;
  final String? message;
  final CartDto? data;
  final ApiError? error;

  const CartResponseModel({this.success, this.message, this.data, this.error});

  factory CartResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CartResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartResponseModelToJson(this);
}

@JsonSerializable()
class ApiError {
  final String? code;
  final String? field;

  const ApiError({this.code, this.field});

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);
}

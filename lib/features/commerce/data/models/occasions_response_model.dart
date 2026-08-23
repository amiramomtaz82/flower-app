import 'package:json_annotation/json_annotation.dart';

import 'occasions_data_model.dart';

part 'occasions_response_model.g.dart';

@JsonSerializable()
class OccasionsResponseModel {
  final OccasionsDataModel data;

  const OccasionsResponseModel({required this.data});

  factory OccasionsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$OccasionsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$OccasionsResponseModelToJson(this);
}

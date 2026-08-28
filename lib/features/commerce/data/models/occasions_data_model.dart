import 'package:json_annotation/json_annotation.dart';

import 'occasion_dto.dart';

part 'occasions_data_model.g.dart';

@JsonSerializable()
class OccasionsDataModel {
  final List<OccasionDTO> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const OccasionsDataModel({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory OccasionsDataModel.fromJson(Map<String, dynamic> json) =>
      _$OccasionsDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$OccasionsDataModelToJson(this);
}

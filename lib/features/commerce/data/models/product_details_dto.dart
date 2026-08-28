import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/product_details_entity.dart';

part 'product_details_dto.g.dart';

@JsonSerializable()
class IncludeDTO {
  final String? name;

  const IncludeDTO({this.name});

  factory IncludeDTO.fromJson(Map<String, dynamic> json) =>
      _$IncludeDTOFromJson(json);

  Map<String, dynamic> toJson() => _$IncludeDTOToJson(this);

  IncludeEntity toEntity() => IncludeEntity(name: name);
}

@JsonSerializable()
class ProductDetailsDTO {
  final String? id;
  final String? name;
  final String? imageUrl;
  final String? currency;
  final num? price;
  final num? originalPrice;
  final num? discountPercentage;
  final String? status;
  final List<String>? images;
  final String? description;
  final List<IncludeDTO>? includes;
  final String? categoryId;
  final List<String>? occasionIds;

  const ProductDetailsDTO({
    this.id,
    this.name,
    this.imageUrl,
    this.currency,
    this.price,
    this.originalPrice,
    this.discountPercentage,
    this.status,
    this.images,
    this.description,
    this.includes,
    this.categoryId,
    this.occasionIds,
  });

  factory ProductDetailsDTO.fromJson(Map<String, dynamic> json) =>
      _$ProductDetailsDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ProductDetailsDTOToJson(this);

  ProductDetailsEntity toEntity() => ProductDetailsEntity(
    id: id,
    name: name,
    imageUrl: imageUrl,
    currency: currency,
    price: price,
    originalPrice: originalPrice,
    discountPercentage: discountPercentage,
    status: status,
    images: images,
    description: description,
    includes: includes?.map((i) => i.toEntity()).toList(),
    categoryId: categoryId,
    occasionIds: occasionIds,
  );
}

import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/product_entity.dart';

part 'product_dto.g.dart';

@JsonSerializable()
class ProductDTO {
  final String? id;
  final String? name;
  final String? imageUrl;
  final String? currency;
  final num? price;
  final num? originalPrice;
  final num? discountPercentage;
  final String? status;
  final bool? isBestSeller;

  const ProductDTO({
    this.id,
    this.name,
    this.imageUrl,
    this.currency,
    this.price,
    this.originalPrice,
    this.discountPercentage,
    this.status,
    this.isBestSeller,
  });

  factory ProductDTO.fromJson(Map<String, dynamic> json) =>
      _$ProductDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ProductDTOToJson(this);

  ProductEntity toEntity() => ProductEntity(
    id: id,
    name: name,
    imageUrl: imageUrl,
    currency: currency,
    price: price,
    originalPrice: originalPrice,
    discountPercentage: discountPercentage,
    status: status,
    isBestSeller: isBestSeller,
  );
}

import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  const ProductEntity({
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

  final String? id;
  final String? name;
  final String? imageUrl;
  final String? currency;
  final num? price;
  final num? originalPrice;
  final num? discountPercentage;
  final String? status;
  final bool? isBestSeller;

  @override
  List<Object?> get props => [
    id,
    name,
    imageUrl,
    currency,
    price,
    originalPrice,
    discountPercentage,
    status,
    isBestSeller,
  ];
}

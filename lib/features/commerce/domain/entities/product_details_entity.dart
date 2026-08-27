import 'package:flower_app/features/commerce/domain/entities/product_entity.dart';

class ProductDetailsEntity extends ProductEntity {
  const ProductDetailsEntity({
    super.id,
    super.name,
    super.imageUrl,
    super.currency,
    super.price,
    super.originalPrice,
    super.discountPercentage,
    super.status,
    this.images,
    this.description,
    this.includes,
    this.categoryId,
    this.occasionIds,
  });

  final List<String>? images;
  final String? description;
  final List<IncludeEntity>? includes;
  final String? categoryId;
  final List<String>? occasionIds;

  @override
  List<Object?> get props => [
        ...super.props,
        images,
        description,
        includes,
        categoryId,
        occasionIds,
      ];
}

class IncludeEntity {
  final String? name;

  const IncludeEntity({this.name});
}

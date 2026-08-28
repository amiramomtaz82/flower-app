import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/features/commerce/domain/entities/product_details_entity.dart';

class ProductDetailsState {
  final Resource<ProductDetailsEntity> resource;
  final int currentImageIndex;

  const ProductDetailsState({
    required this.resource,
    this.currentImageIndex = 0,
  });

  ProductDetailsState copyWith({
    Resource<ProductDetailsEntity>? resource,
    int? currentImageIndex,
  }) {
    return ProductDetailsState(
      resource: resource ?? this.resource,
      currentImageIndex: currentImageIndex ?? this.currentImageIndex,
    );
  }
}

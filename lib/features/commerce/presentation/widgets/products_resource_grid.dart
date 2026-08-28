import 'package:flower_app/config/resource/rsource.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/product_entity.dart';
import 'centered_message.dart';
import 'poduct_grid.dart';

/// Renders a products [Resource] as a grid, covering the loading, error and
/// empty states along the way. Shared by the categories page and the occasion
/// page, which differ only in what they call an empty result — hence
/// [emptyMessage].
class ProductsResourceGrid extends StatelessWidget {
  const ProductsResourceGrid({
    super.key,
    required this.resource,
    required this.emptyMessage,
  });

  final Resource<List<ProductEntity>> resource;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (resource.isLoading || resource.status == ApiStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (resource.isError) {
      return CenteredMessage(text: resource.errorMessage);
    }

    final products = resource.data ?? const <ProductEntity>[];
    if (products.isEmpty) {
      return CenteredMessage(text: emptyMessage);
    }

    return ProductGrid(products: products);
  }
}

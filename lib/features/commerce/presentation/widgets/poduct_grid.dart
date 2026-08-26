import 'package:flutter/cupertino.dart';

import '../../domain/entities/product_entity.dart';
import 'custom_product_card.dart';



class ProductGrid extends StatelessWidget {
  final List<ProductEntity> products;

  const ProductGrid({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 250,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return CustomProductCard(
          product: products[index],
        );
      },
    );
  }
}









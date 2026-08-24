import 'package:flutter/material.dart';

import '../../../api/data_source_impl/local/dummy_data.dart';
import '../../widgets/poduct_grid.dart';
import '../../widgets/screen_header.dart';

class CategoryProductsView extends StatelessWidget {
  const CategoryProductsView({
    super.key,
    required this.categoryId,
    this.categoryName,
  });

  final String categoryId;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    // TODO: replace with GetProductsByCategoryUseCase(categoryId: categoryId)
    final products = dummyList;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: ScreenHeader(
                title: categoryName ?? 'Category',
                subtitle: 'Bloom with our exquisite best sellers',
              ),
            ),
            Expanded(child: ProductGrid(products: products)),
          ],
        ),
      ),
    );
  }
}

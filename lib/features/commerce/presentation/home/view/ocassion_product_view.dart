import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/features/commerce/domain/entities/product_entity.dart';
import 'package:flower_app/features/commerce/presentation/widgets/screen_header.dart';
import 'package:flutter/material.dart';

import '../../../api/data_source_impl/local/dummy_data.dart';
import '../../../api/data_source_impl/local/dummy_occasions.dart';
import '../../../domain/entities/product_entity.dart';
import '../../widgets/category_tabs_bar.dart';
import '../../widgets/poduct_grid.dart';
import '../widgets/home_search_bar.dart';

class OccasionProductsView extends StatefulWidget {
  final String? selectedOccasionId;

  const OccasionProductsView({super.key, this.selectedOccasionId});

  @override
  State<OccasionProductsView> createState() => _OccasionProductsViewState();
}

class _OccasionProductsViewState extends State<OccasionProductsView> {
  int _selectedIndex = 0;

  List<String> get _labels =>
      dummyOccasions.map((occasion) => occasion.name).toList();

  @override
  void initState() {
    super.initState();

    if (widget.selectedOccasionId != null) {
      final index = dummyOccasions.indexWhere(
        (occasion) => occasion.id == widget.selectedOccasionId,
      );

      if (index != -1) {
        _selectedIndex = index;
      }
    }
  }

  List<ProductEntity> get _products {
    final occasionId = dummyOccasions[_selectedIndex].id;

    return dummyProductsByOccasion[occasionId] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = LightColors();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ---------- search, sort ----------
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ScreenHeader(
                title: 'Occasions',
                onBack: () {
                  Navigator.pop(context);
                },
              ),
            ),

            // ---------- occasion tabs ----------
            CategoryTabsBar(
              labels: _labels,
              selectedIndex: _selectedIndex,
              onSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),

            // ---------- products ----------
            Expanded(child: ProductGrid(products: _products)),
          ],
        ),
      ),
    );
  }
}

final Map<String, List<ProductEntity>> dummyProductsByOccasion = {
  '1': dummyList.where((product) => product.occasionId == '1').toList(),
  '2': dummyList.where((product) => product.occasionId == '2').toList(),
  '3': dummyList.where((product) => product.occasionId == '3').toList(),
  '4': dummyList.where((product) => product.occasionId == '4').toList(),
};

final dummyList = [
  ProductEntity(id: '1', name: 'Birthday Flower', price: 500, occasionId: '1'),
  ProductEntity(id: '2', name: 'Birthday Rose', price: 600, occasionId: '1'),
  ProductEntity(id: '3', name: 'Wedding Flower', price: 700, occasionId: '2'),
  ProductEntity(id: '4', name: 'Wedding Rose', price: 800, occasionId: '2'),
];

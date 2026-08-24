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

final dummyList = [
  // Wedding
  ProductEntity(
    id: '1',
    name: 'Wedding White Roses',
    price: 500,
    occasionId: '1',
  ),
  ProductEntity(
    id: '2',
    name: 'Elegant Wedding Bouquet',
    price: 650,
    occasionId: '1',
  ),
  ProductEntity(
    id: '3',
    name: 'Wedding Pink Flowers',
    price: 750,
    occasionId: '1',
  ),
  ProductEntity(
    id: '4',
    name: 'Luxury Wedding Bouquet',
    price: 900,
    occasionId: '1',
  ),
  ProductEntity(
    id: '5',
    name: 'White Lily Wedding',
    price: 850,
    occasionId: '1',
  ),

  // Birthday
  ProductEntity(
    id: '6',
    name: 'Birthday Roses',
    price: 600,
    occasionId: '2',
  ),
  ProductEntity(
    id: '7',
    name: 'Birthday Colorful Bouquet',
    price: 550,
    occasionId: '2',
  ),
  ProductEntity(
    id: '8',
    name: 'Birthday Pink Bouquet',
    price: 700,
    occasionId: '2',
  ),
  ProductEntity(
    id: '9',
    name: 'Birthday Gift Flowers',
    price: 800,
    occasionId: '2',
  ),
  ProductEntity(
    id: '10',
    name: 'Happy Birthday Bouquet',
    price: 950,
    occasionId: '2',
  ),

  // Graduation
  ProductEntity(
    id: '11',
    name: 'Graduation Flowers',
    price: 500,
    occasionId: '3',
  ),
  ProductEntity(
    id: '12',
    name: 'Graduation Rose Bouquet',
    price: 650,
    occasionId: '3',
  ),
  ProductEntity(
    id: '13',
    name: 'Graduation Gift Bouquet',
    price: 700,
    occasionId: '3',
  ),
  ProductEntity(
    id: '14',
    name: 'Graduation Pink Flowers',
    price: 750,
    occasionId: '3',
  ),
  ProductEntity(
    id: '15',
    name: 'Congratulations Bouquet',
    price: 850,
    occasionId: '3',
  ),
];

final Map<String, List<ProductEntity>> dummyProductsByOccasion = {
  '1': dummyList
      .where((product) => product.occasionId == '1')
      .toList(),

  '2': dummyList
      .where((product) => product.occasionId == '2')
      .toList(),

  '3': dummyList
      .where((product) => product.occasionId == '3')
      .toList(),
};
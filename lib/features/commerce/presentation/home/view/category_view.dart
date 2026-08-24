import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../api/data_source_impl/local/dummy_categories.dart';
import '../../../api/data_source_impl/local/dummy_data.dart';
import '../../../domain/entities/product_entity.dart';
import '../../widgets/category_tabs_bar.dart';
import '../../widgets/poduct_grid.dart';
import '../widgets/home_search_bar.dart';

class CategoryView extends StatefulWidget {
  final String? selectedCategoryId;

  const CategoryView({
    super.key,
    this.selectedCategoryId,
  });

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  int _selectedIndex = 0;

  List<String> get _labels =>
    dummyCategories.map((category) => category.name).toList();

@override
void initState() {
  super.initState();

  if (widget.selectedCategoryId != null) {
    final index = dummyCategories.indexWhere(
      (category) => category.id == widget.selectedCategoryId,
    );

    if (index != -1) {
      _selectedIndex = index;
    }
  }
}

  List<ProductEntity> get _products {
    final categoryId = dummyCategories[_selectedIndex].id;

    return dummyProductsByCategory[categoryId] ?? [];
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Row(
                children: [
                  const Expanded(
                    child: HomeSearchBar(),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colors.hint,
                        ),
                      ),
                      child: Icon(
                        Icons.sort,
                        color: colors.darkGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ---------- category tabs ----------
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
            Expanded(
              child: ProductGrid(
                products: _products,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/category_entity.dart';
import '../../widgets/centered_message.dart';
import '../../widgets/products_resource_grid.dart';
import '../../widgets/selection_tabs.dart';
import '../manager/categories_cubit.dart';
import '../manager/categories_events.dart';
import '../manager/categories_state.dart';

class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<CategoriesCubit, CategoriesState>(
          builder: (context, state) {
            final categories = state.categoriesResource;

            if (categories.isLoading ||
                categories.status == ApiStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (categories.isError) {
              return CenteredMessage(text: categories.errorMessage);
            }

            final data = categories.data ?? const <CategoryEntity>[];
            if (data.isEmpty) {
              return CenteredMessage(text: AppStrings.noCategoriesYet.tr());
            }

            return Column(
              children: [
                const SizedBox(height: 16),
                SizedBox(
                  height: 44,
                  child: SelectionTabs(
                    tabs: [
                      for (final category in data)
                        SelectionTab(id: category.id, label: category.name),
                    ],
                    selectedId: state.selectedCategoryId,
                    onSelected: (categoryId) => context
                        .read<CategoriesCubit>()
                        .doEvents(CategorySelected(categoryId)),
                  ),
                ),
                Expanded(
                  child: ProductsResourceGrid(
                    resource: state.productsResource,
                    emptyMessage: AppStrings.noProductsInThisCategory.tr(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

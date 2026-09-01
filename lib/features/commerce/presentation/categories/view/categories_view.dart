import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/core/pagination/pagination_state.dart';
import 'package:flower_app/core/pagination/presentaion/pagination_footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/product_entity.dart';
import '../../widgets/centered_message.dart';
import '../../widgets/custom_product_card.dart';
import '../../widgets/selection_tabs.dart';
import '../manager/categories_cubit.dart';
import '../manager/categories_events.dart';
import '../manager/categories_state.dart';
import '../widgets/categories_filter_bottom_sheet.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CategoriesCubit>().doEvents(CategoriesLoadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state.categoriesResource.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.categoriesResource.isError) {
          return CenteredMessage(
            text: state.categoriesResource.errorMessage ??
                AppStrings.somethingWentWrong.tr(),
          );
        }

        final data = state.categoriesResource.data ?? [];
        if (data.isEmpty) {
          return CenteredMessage(
            text: AppStrings.noCategoriesYet.tr(),
          );
        }

        final productsPagination = state.productsPagination;
        final products = productsPagination.resource.data ?? [];

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push(AppRoutes.search),
                          child: AbsorbPointer(
                            child: TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: AppStrings.search.tr(),
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: colorScheme.surfaceContainerHighest,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => CategoriesFilterBottomSheet.show(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            border: Border.all(color: colorScheme.outlineVariant),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.filter_list, color: colorScheme.onSurfaceVariant),
                        ),
                      )
                    ],
                  ),
                ),
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
                  child: _buildProductsGrid(productsPagination, products, colorScheme),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductsGrid(PaginationState<ProductEntity> state, List<ProductEntity> products, ColorScheme colorScheme) {
    if (state.resource.isLoading && products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.resource.isError && products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.resource.errorMessage ?? 'error'.tr()),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<CategoriesCubit>().doEvents(CategoriesRetry()),
              child: Text('retry'.tr()),
            ),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return CenteredMessage(text: AppStrings.noProductsInThisCategory.tr());
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 230,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return CustomProductCard(product: products[index]);
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: PaginationFooter(
              isLoadingMore: state.isLoadingMore,
              hasNextPage: state.hasNextPage,
              loadMoreError: state.loadMoreError,
              onRetry: () =>
                  context.read<CategoriesCubit>().doEvents(CategoriesRetry()),
            ),
          ),
        ),
      ],
    );
  }
}


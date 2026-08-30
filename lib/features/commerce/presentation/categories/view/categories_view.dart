import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/pagination/pagination_state.dart';
import 'package:flower_app/core/pagination/presentaion/pagination_footer.dart';
import 'package:flower_app/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/category_entity.dart';
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
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CategoriesCubit>().doEvents(CategoriesLoadMore());
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<CategoriesCubit>().doEvents(CategoriesSearchChanged(query));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => CategoriesFilterBottomSheet.show(context),
        backgroundColor: colorScheme.primary,
        icon: const Icon(Icons.filter_list, color: Colors.white),
        label: const Text('Filter', style: TextStyle(color: Colors.white)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: BlocConsumer<CategoriesCubit, CategoriesState>(
          listenWhen: (previous, current) {
             // If category changed, clear search text field
             return previous.selectedCategoryId != current.selectedCategoryId;
          },
          listener: (context, state) {
            _searchController.clear();
          },
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

            final productsPagination = state.productsPagination;
            final products = productsPagination.resource.data ?? [];

            return Column(
              children: [
                const SizedBox(height: 16),
                
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _searchController,
                          hintText: 'Search',
                          prefixIcon: const Icon(Icons.search),
                          onChanged: _onSearchChanged,
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

                // Selection Tabs
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
                
                // Products Grid
                Expanded(
                  child: _buildProductsGrid(productsPagination, products, colorScheme),
                ),
              ],
            );
          },
        ),
      ),
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
            // Extra padding at the bottom so the floating button doesn't hide the loader
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


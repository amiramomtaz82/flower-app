import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/pagination/presentaion/pagination_footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/product_entity.dart';
import '../../widgets/centered_message.dart';
import '../../widgets/custom_product_card.dart';
import '../manager/search_cubit.dart';
import '../manager/search_events.dart';
import '../manager/search_state.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<SearchCubit>().doEvents(SearchLoadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) => context
                    .read<SearchCubit>()
                    .doEvents(SearchQueryChanged(value)),
                decoration: InputDecoration(
                  hintText: AppStrings.search.tr(),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                      context
                          .read<SearchCubit>()
                          .doEvents(SearchQueryChanged(''));
                    },
                  ),
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
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  return _buildBody(state, colorScheme);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(SearchState state, ColorScheme colorScheme) {
    final keyword = state.keyword;
    final pagination = state.productsPagination;
    final products = pagination.resource.data ?? <ProductEntity>[];

    if (keyword.trim().isEmpty) {
      return Center(
        child: Text(
          AppStrings.searchForAnyProduct.tr(),
          style: TextStyle(color: colorScheme.primary),
        ),
      );
    }

    if (pagination.resource.isLoading && products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pagination.resource.isError && products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(pagination.resource.errorMessage ?? AppStrings.somethingWentWrong.tr()),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () =>
                  context.read<SearchCubit>().doEvents(SearchRetry()),
              child: Text('Retry'.tr()),
            ),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return CenteredMessage(
        text: AppStrings.noProductsInThisCategory.tr(),
      );
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
            padding: const EdgeInsets.only(bottom: 24),
            child: PaginationFooter(
              isLoadingMore: pagination.isLoadingMore,
              hasNextPage: pagination.hasNextPage,
              loadMoreError: pagination.loadMoreError,
              onRetry: () =>
                  context.read<SearchCubit>().doEvents(SearchRetry()),
            ),
          ),
        ),
      ],
    );
  }
}

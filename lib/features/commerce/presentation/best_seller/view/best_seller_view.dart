import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/core/pagination/pagination_state.dart';
import 'package:flower_app/core/pagination/presentaion/pagination_footer.dart';
import 'package:flower_app/features/commerce/domain/entities/product_entity.dart';
import 'package:flower_app/features/commerce/presentation/best_seller/view_model/best_seller_view_model.dart';
import 'package:flower_app/features/commerce/presentation/best_seller/view_model/best_seller_event.dart';
import 'package:flower_app/features/commerce/presentation/widgets/custom_product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BestSellerView extends StatefulWidget {
  const BestSellerView({super.key});

  @override
  State<BestSellerView> createState() => _BestSellerViewState();
}

class _BestSellerViewState extends State<BestSellerView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<BestSellerViewModel>().doEvent(LoadInitialBestSellers());
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
      context.read<BestSellerViewModel>().doEvent(LoadMoreBestSellers());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: colorScheme.onSurface),
        title: Text('best_seller'.tr(), style: textTheme.titleLarge),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'Bloom with our exquisite best sellers'.tr(),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<BestSellerViewModel, PaginationState<ProductEntity>>(
        builder: (context, state) {
          if (state.resource.isLoading && (state.resource.data?.isEmpty ?? true)) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (state.resource.status == ApiStatus.error &&
              (state.resource.data?.isEmpty ?? true)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.resource.errorMessage ?? 'error'.tr()),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<BestSellerViewModel>().doEvent(LoadInitialBestSellers()),
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            );
          }

          final products = state.resource.data ?? [];

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
                child: PaginationFooter(
                  isLoadingMore: state.isLoadingMore,
                  hasNextPage: state.hasNextPage,
                  loadMoreError: state.loadMoreError,
                  onRetry: () =>
                      context.read<BestSellerViewModel>().doEvent(RetryBestSellers()),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flower_app/core/pagination/pagination_controller.dart';
import 'package:flower_app/core/pagination/pagination_state.dart';
import 'package:flower_app/features/commerce/domain/entities/product_entity.dart';
import 'package:flower_app/features/commerce/domain/use_cases/get_best_sellers_use_case.dart';
import 'package:flower_app/features/commerce/presentation/best_seller/view_model/best_seller_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../config/resource/rsource.dart';

const String kBestSellerSort = 'sold_count';
const int kPageSize = 10;

@injectable
class BestSellerViewModel extends Cubit<PaginationState<ProductEntity>> {
  final GetBestSellersUseCase _getBestSellersUseCase;
  late final PaginationController<ProductEntity> _paginationController;

  BestSellerViewModel(this._getBestSellersUseCase)
    : super(PaginationState.initial()) {
    _paginationController = PaginationController<ProductEntity>(
      fetchPage: (page) => _getBestSellersUseCase(
        page: page,
        pageSize: kPageSize,
        sort: kBestSellerSort,
      ),
    );
  }

  void doEvent(BestSellerEvent event) {
    switch (event) {
      case LoadInitialBestSellers():
        _loadInitial();
      case LoadMoreBestSellers():
        _loadMore();
      case RetryBestSellers():
        _retry();
      case RefreshBestSellers():
        _refresh();
    }
  }

  Future<void> _loadInitial() async {
    emit(_paginationController.state.copyWith(resource: Resource.loading()));
    final newState = await _paginationController.loadInitialPage();
    emit(newState);
  }

  Future<void> _loadMore() async {
    final newState = await _paginationController.loadNextPage();
    emit(newState);
  }

  Future<void> _retry() async {
    final newState = await _paginationController.retry();
    emit(newState);
  }

  void _refresh() {
    _paginationController.reset();
    _loadInitial();
  }
}

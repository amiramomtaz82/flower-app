import 'package:flower_app/core/pagination/pagination_controller.dart';
import 'package:flower_app/core/pagination/pagination_state.dart';
import 'package:flower_app/features/commerce/domain/entities/product_entity.dart';
import 'package:flower_app/features/commerce/domain/use_cases/get_best_sellers_use_case.dart';
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

  Future<void> loadInitial() async {
    emit(_paginationController.state.copyWith(resource: Resource.loading()));
    final newState = await _paginationController.loadInitialPage();
    emit(newState);
  }

  Future<void> loadMore() async {
    final newState = await _paginationController.loadNextPage();
    emit(newState);
  }

  Future<void> retry() async {
    final newState = await _paginationController.retry();
    emit(newState);
  }

  void refresh() {
    _paginationController.reset();
    loadInitial();
  }
}

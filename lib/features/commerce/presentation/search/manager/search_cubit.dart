import 'dart:async';

import 'package:flower_app/core/pagination/pagination_controller.dart';
import 'package:flower_app/core/pagination/pagination_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../config/resource/rsource.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/use_cases/get_products_use_case.dart';
import 'search_events.dart';
import 'search_state.dart';

const int kSearchPageSize = 10;
const Duration kSearchDebounce = Duration(milliseconds: 500);

@injectable
class SearchCubit extends Cubit<SearchState> {
  final GetProductsUseCase _getProductsUseCase;
  late final PaginationController<ProductEntity> _paginationController;
  Timer? _debounce;

  SearchCubit(this._getProductsUseCase) : super(SearchState.initial()) {
    _paginationController = PaginationController<ProductEntity>(
      fetchPage: (page) => _getProductsUseCase(
        keyword: state.keyword.isEmpty ? null : state.keyword,
        pageNumber: page,
        pageSize: kSearchPageSize,
      ),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  Future<void> doEvents(SearchEvent event) async {
    switch (event) {
      case SearchQueryChanged():
        _onQueryChanged(event.keyword);
      case SearchLoadMore():
        _loadMore();
      case SearchRetry():
        _retry();
    }
  }

  void _onQueryChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    emit(state.copyWith(keyword: keyword));
    if (keyword.trim().isEmpty) {
      _paginationController.reset();
      emit(state.copyWith(
        productsPagination: PaginationState.initial(),
      ));
      return;
    }
    _debounce = Timer(kSearchDebounce, () {
      _reloadProducts();
    });
  }

  Future<void> _reloadProducts() async {
    _paginationController.reset();

    emit(state.copyWith(
      productsPagination: _paginationController.state.copyWith(
        resource: Resource.loading(),
      ),
    ));

    final newState = await _paginationController.loadInitialPage();
    emit(state.copyWith(productsPagination: newState));
  }

  Future<void> _loadMore() async {
    final newState = await _paginationController.loadNextPage();
    emit(state.copyWith(productsPagination: newState));
  }

  Future<void> _retry() async {
    final newState = await _paginationController.retry();
    emit(state.copyWith(productsPagination: newState));
  }
}

import 'dart:async';

import 'package:flower_app/core/pagination/pagination_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../config/base_response/base_response.dart';
import '../../../../../config/resource/rsource.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/use_cases/get_categories_use_case.dart';
import '../../../domain/use_cases/get_products_use_case.dart';
import 'categories_events.dart';
import 'categories_state.dart';
import 'sort_option.dart';

const int kCategoryProductsPageSize = 10;
const Duration kSearchDebounce = Duration(milliseconds: 500);

@injectable
class CategoriesCubit extends Cubit<CategoriesState> {
  final GetCategoriesUseCase _getCategoriesUseCase;
  late final PaginationController<ProductEntity> _paginationController;
  Timer? _debounce;

  CategoriesCubit(
    this._getCategoriesUseCase,
    GetProductsUseCase getProductsUseCase,
  ) : super(CategoriesState.initial()) {
    _paginationController = PaginationController<ProductEntity>(
      fetchPage: (page) => getProductsUseCase(
        categoryId: state.selectedCategoryId,
        keyword: state.keyword,
        sortBy: state.sortOption?.apiValue,
        pageNumber: page,
        pageSize: kCategoryProductsPageSize,
      ),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  Future<void> doEvents(CategoriesEvent event) async {
    switch (event) {
      case CategoriesStarted():
        await _loadCategories(event.initialCategoryId);
      case CategorySelected():
        await _selectCategory(event.categoryId);
      case CategoriesSearchChanged():
        _onSearchChanged(event.keyword);
      case CategoriesSortChanged():
        _sortChanged(event.sortOption);
      case CategoriesLoadMore():
        _loadMore();
      case CategoriesRetry():
        _retry();
    }
  }

  Future<void> _loadCategories(String? initialCategoryId) async {
    emit(state.copyWith(categoriesResource: Resource.loading()));

    final result = await _getCategoriesUseCase();
    switch (result) {
      case SuccessResponse<List<CategoryEntity>>():
        emit(state.copyWith(categoriesResource: Resource.success(result.data)));
        if (result.data.isEmpty) return;

        final selected = result.data.any((c) => c.id == initialCategoryId)
            ? initialCategoryId!
            : result.data.first.id;
        await _selectCategory(selected);

      case ErrorResponse<List<CategoryEntity>>():
        emit(
          state.copyWith(categoriesResource: Resource.error(result.errMessage)),
        );
    }
  }

  Future<void> _selectCategory(String categoryId) async {
    if (state.selectedCategoryId == categoryId) return;
    _paginationController.reset();
    emit(state.copyWith(
      selectedCategoryId: categoryId,
      clearKeyword: true,
      productsPagination: _paginationController.state.copyWith(
        resource: Resource.loading(),
      ),
    ));
    await _fetchProducts();
  }

  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    emit(state.copyWith(keyword: keyword.isEmpty ? null : keyword));
    _debounce = Timer(kSearchDebounce, () {
      _reloadProducts();
    });
  }

  void _sortChanged(SortOption sortOption) {
    emit(state.copyWith(sortOption: sortOption));
    _reloadProducts();
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

  Future<void> _fetchProducts() async {
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

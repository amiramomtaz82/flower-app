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

const int kCategoryProductsPageSize = 10;

@injectable
class CategoriesCubit extends Cubit<CategoriesState> {
  final GetCategoriesUseCase _getCategoriesUseCase;
  late final PaginationController<ProductEntity> _paginationController;

  CategoriesCubit(
    this._getCategoriesUseCase,
    GetProductsUseCase getProductsUseCase,
  ) : super(CategoriesState.initial()) {
    _paginationController = PaginationController<ProductEntity>(
      fetchPage: (page) => getProductsUseCase(
        categoryId: state.selectedCategoryId,
        keyword: state.keyword,
        sortBy: state.sortBy,
        pageNumber: page,
        pageSize: kCategoryProductsPageSize,
      ),
    );
  }

  Future<void> doEvents(CategoriesEvent event) async {
    switch (event) {
      case CategoriesStarted():
        await _loadCategories(event.initialCategoryId);
      case CategorySelected():
        _selectCategory(event.categoryId);
      case CategoriesSearchChanged():
        _searchChanged(event.keyword);
      case CategoriesSortChanged():
        _sortChanged(event.sortBy);
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
        _selectCategory(selected);

      case ErrorResponse<List<CategoryEntity>>():
        emit(
          state.copyWith(categoriesResource: Resource.error(result.errMessage)),
        );
    }
  }

  void _selectCategory(String categoryId) {
    if (state.selectedCategoryId == categoryId) return;

    emit(state.copyWith(
      selectedCategoryId: categoryId,
      keyword: null,
    ));
    _reloadProducts();
  }

  void _searchChanged(String keyword) {
    emit(state.copyWith(keyword: keyword.isEmpty ? null : keyword));
    _reloadProducts();
  }

  void _sortChanged(String sortBy) {
    emit(state.copyWith(sortBy: sortBy));
    _reloadProducts();
  }

  Future<void> _reloadProducts() async {
    _paginationController.reset();

    emit(state.copyWith(
      productsPagination: _paginationController.state.copyWith(resource: Resource.loading())
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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../config/base_response/base_response.dart';
import '../../../../../config/resource/rsource.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/use_cases/get_categories_use_case.dart';
import '../../../domain/use_cases/get_products_by_category_use_case.dart';
import 'categories_events.dart';
import 'categories_state.dart';

@injectable
class CategoriesCubit extends Cubit<CategoriesState> {
  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetProductsByCategoryUseCase _getProductsByCategoryUseCase;

  CategoriesCubit(
    this._getCategoriesUseCase,
    this._getProductsByCategoryUseCase,
  ) : super(CategoriesState.initial());

  Future<void> doEvents(CategoriesEvent event) async {
    switch (event) {
      case CategoriesStarted():
        await _loadCategories(event.initialCategoryId);
      case CategorySelected():
        await _loadProducts(event.categoryId);
    }
  }

  Future<void> _loadCategories(String? initialCategoryId) async {
    emit(state.copyWith(categoriesResource: Resource.loading()));

    final result = await _getCategoriesUseCase();
    switch (result) {
      case SuccessResponse<List<CategoryEntity>>():
        emit(state.copyWith(categoriesResource: Resource.success(result.data)));
        if (result.data.isEmpty) return;

        // the category the user tapped on Home wins, as long as it is still
        // one of the tabs; otherwise open on the first one.
        final selected = result.data.any((c) => c.id == initialCategoryId)
            ? initialCategoryId!
            : result.data.first.id;
        await _loadProducts(selected);

      case ErrorResponse<List<CategoryEntity>>():
        emit(
          state.copyWith(categoriesResource: Resource.error(result.errMessage)),
        );
    }
  }

  Future<void> _loadProducts(String categoryId) async {
    emit(
      state.copyWith(
        selectedCategoryId: categoryId,
        productsResource: Resource.loading(),
      ),
    );

    final result = await _getProductsByCategoryUseCase(categoryId: categoryId);

    // a faster tap on another tab already took over
    if (state.selectedCategoryId != categoryId) return;

    emit(
      state.copyWith(
        productsResource: switch (result) {
          SuccessResponse() => Resource.success(result.data),
          ErrorResponse() => Resource.error(result.errMessage),
        },
      ),
    );
  }
}

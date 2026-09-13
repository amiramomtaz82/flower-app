import 'sort_option.dart';

sealed class CategoriesEvent {}

class CategoriesStarted extends CategoriesEvent {
  CategoriesStarted({this.initialCategoryId});

  final String? initialCategoryId;
}

class CategorySelected extends CategoriesEvent {
  CategorySelected(this.categoryId);

  final String categoryId;
}

class CategoriesSearchChanged extends CategoriesEvent {
  CategoriesSearchChanged(this.keyword);

  final String keyword;
}

class CategoriesSortChanged extends CategoriesEvent {
  CategoriesSortChanged(this.sortOption);

  final SortOption sortOption;
}

class CategoriesLoadMore extends CategoriesEvent {}

class CategoriesRetry extends CategoriesEvent {}

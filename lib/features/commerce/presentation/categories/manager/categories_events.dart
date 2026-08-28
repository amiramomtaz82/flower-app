sealed class CategoriesEvent {}

/// [initialCategoryId] is the category the user tapped on Home, if any.
class CategoriesStarted extends CategoriesEvent {
  CategoriesStarted({this.initialCategoryId});

  final String? initialCategoryId;
}

class CategorySelected extends CategoriesEvent {
  CategorySelected(this.categoryId);

  final String categoryId;
}

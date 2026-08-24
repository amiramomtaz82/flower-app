class AppRoutes {
  AppRoutes._();
  static const String login = '/login';
  static const String home = '/commerce';
  static const String categories = '/categories';
  static const String cart = '/cart';
  static const String profile = '/profile';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String test = '/test';

  static const String productDetails = '/productDetails';

  /// Relative sub-route, registered under both the home and categories
  /// branches so the bottom bar stays visible whichever tab you came from.
  static const String categoryProducts = 'category/:categoryId';
static const String occasionProducts = '/occasion-products';
  /// Full location when opening a category from the home tab.
  static String homeCategoryProducts(String categoryId) =>
      '$home/category/$categoryId';

  /// Full location when opening a category from the categories tab.
  static String tabCategoryProducts(String categoryId) =>
      '$categories/category/$categoryId';
}

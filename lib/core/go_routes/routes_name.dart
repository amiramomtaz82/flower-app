class AppRoutes {
  AppRoutes._();
  static const String login = '/login';
  static const String home = '/commerce';
  static const String categories = '/categories';
  static const String cart = '/cart';
  static const String profile = '/profile';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String addAddress= '/addAddress';
  static const String savedAddresses = '/saved-addresses';

  static const String addressDetails = '/address-details/:addressId';
  static const String editAddress = '/edit-address/:addressId';

  static String addressDetailsFor(String addressId) =>
      '/address-details/${Uri.encodeComponent(addressId)}';

  static String editAddressFor(String addressId) =>
      '/edit-address/${Uri.encodeComponent(addressId)}';

  static const String productDetails = '/product-details';

  static const String bestSeller = '/best-seller';

  static const String categoryIdParam = 'categoryId';

  static String categoriesForCategory(String categoryId) =>
      '$categories?$categoryIdParam=${Uri.encodeQueryComponent(categoryId)}';

  static const String occasions = '/occasions';

  static const String occasionIdParam = 'occasionId';

  static String occasionsForOccasion(String occasionId) =>
      '$occasions?$occasionIdParam=${Uri.encodeQueryComponent(occasionId)}';
}

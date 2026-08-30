import 'package:flutter_dotenv/flutter_dotenv.dart';

class Endpoints {
  Endpoints._();

  static String get baseUrl => dotenv.env['BASE_URL']!;

  static const String loginEndPoint = '/auth/login';
  static const String register = '/auth/register';
  static const String forgetPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String addAddress = '/address/users/me/addresses';
  static const String getAddresses="/address/users/me/addresses";
  static const String getAreas = '/address/api/areas';
  static const String setDefaultAddress= "/address/api/addresses/{id}/default";

  // Commerce (routed through the API Gateway's /catalog prefix)
  static const String homeSections = '/catalog/home/sections';
  static const String categories = '/catalog/categories';
  static const String occasions = '/catalog/occasions';
  static const String products = '/catalog/products';
  static const String productsByCategory = '/catalog/products/by-category';
  static const String productById = '/catalog/products/{productId}';

  // Best sellers has no dedicated endpoint (backend won't add one) — this is
  // the occasion the backend seeds best-selling products under, so
  // getBestSellers reuses `products` filtered by this fixed occasionId.
  static const String bestSellersOccasionId =
      '55555555-5555-5555-5555-555555555555';
}

/// Query/path parameter keys for [Endpoints] — kept alongside them since
/// retrofit's @Query/@Path annotations need compile-time constant strings.
class QueryParams {
  QueryParams._();

  static const String occasionId = 'occasionId';
  static const String categoryId = 'categoryId';
  static const String productId = 'productId';
  static const String pageNumber = 'pageNumber';
  static const String pageSize = 'pageSize';

  static const String addAddress = '/address/users/me/addresses';
  static const String getAddresses="/address/users/me/addresses";
  static const String getAreas = '/address/api/areas';
}

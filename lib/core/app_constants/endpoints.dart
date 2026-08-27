import 'package:flutter_dotenv/flutter_dotenv.dart';

class Endpoints {
  Endpoints._();

  static String get baseUrl => dotenv.env['BASE_URL']!;

  static const String loginEndPoint = '/auth/login';
  static const String register = '/auth/register';
  static const String forgetPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';

  static const String products = '/catalog/products';
  static String productDetails(String id) => '/catalog/products/$id';
  static const String productsByCategory = '/catalog/products/by-category';
  static const String categories = '/catalog/categories';

  static const String bestSellersOccasionId = '55555555-5555-5555-5555-555555555555';
}

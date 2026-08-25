import 'package:flutter_dotenv/flutter_dotenv.dart';

class Endpoints {
  Endpoints._();

  static String get baseUrl => dotenv.env['BASE_URL']!;

  // Auth
  static const String loginEndPoint = '/auth/login';
  static const String register = '/auth/register';
  static const String forgetPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';

  // Commerce (routed through the API Gateway's /catalog prefix)
  static const String homeSections = '/catalog/home/sections';
  static const String categories = '/catalog/categories';
  static const String occasions = '/catalog/occasions';
  static const String products = '/catalog/products';
  static const String productsByCategory = '/catalog/products/by-category';
  static const String productById = '/catalog/products/{productId}';
}

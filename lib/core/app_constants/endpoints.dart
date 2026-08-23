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

  // Commerce
  static const String categories = '/categories';
  static const String occasions = '/occasions';
  static const String products = '/products';
  static const String productsByCategory = '/products/by-category';
  static const String productById = '/products/{productId}';
}

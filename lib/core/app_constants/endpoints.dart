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

  static const String addAddress = '/address/users/me/addresses';
  static const String getAddresses="/address/users/me/addresses";
  static const String getAreas = '/address/api/areas';
}

import 'package:dio/dio.dart';
import '../../core/app_constants/app_strings.dart';
import 'status_code_mapper.dart';

class DioExceptionMapper {
  DioExceptionMapper._();

  static String toMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return AppStrings.connectionTimeout;
      case DioExceptionType.connectionError:
        return AppStrings.noInternetConnection;
      case DioExceptionType.badCertificate:
        return AppStrings.invalidCertificate;
      case DioExceptionType.cancel:
        return AppStrings.requestCancelled;
      // The backend returned an error response,
      //we can map the status code to a user-friendly message
      case DioExceptionType.badResponse:
        return StatusCodeMapper.toMessage(error.response?.statusCode);
      default:
        return AppStrings.checkYourConnection;
    }
  }
}

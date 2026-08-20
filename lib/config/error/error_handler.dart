import 'package:dio/dio.dart';
import '../../core/app_constants/app_strings.dart';
import 'backend_message_extractor.dart';
import 'dio_exception_mapper.dart';

class ErrorHandler {
  ErrorHandler._();

  static String extractErrorMessage(Object error) {
    if (error is DioException) {
      final backendMessage = BackendMessageExtractor.extract(error);
      if (backendMessage != null) return backendMessage;

      return DioExceptionMapper.toMessage(error);
    } else {
      return AppStrings.somethingWentWrong;
    }
  }

  static int? extractStatusCode(Object error) {
    if (error is DioException) return error.response?.statusCode;
    return null;
  }
}

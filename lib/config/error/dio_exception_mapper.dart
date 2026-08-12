import 'package:dio/dio.dart';
import 'status_code_mapper.dart';

class DioExceptionMapper {
  DioExceptionMapper._();

  static String toMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return 'Connection timeout, please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection, please check your network.';
      case DioExceptionType.badCertificate:
        return 'Invalid certificate, please try again later.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      // The backend returned an error response,
      //we can map the status code to a user-friendly message
      case DioExceptionType.badResponse:
        return StatusCodeMapper.toMessage(error.response?.statusCode);
      default:
        return 'Something went wrong, please check your connection.';
    }
  }
}

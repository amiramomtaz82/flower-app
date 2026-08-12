import 'package:dio/dio.dart';

sealed class BaseResponse<T> {
  const BaseResponse();
}

class SuccessResponse<T> extends BaseResponse<T> {
  final T data;

  const SuccessResponse(this.data);
}

class ErrorResponse<T> extends BaseResponse<T> {
  final Exception? error;
  final String errMessage;

  ErrorResponse({this.error, String? errMessage})
      : errMessage = error != null
      ? _extractErrorMessage(error)
      : (errMessage ?? 'Something went wrong, please try again');

  static String _extractErrorMessage(Exception error) {
    if (error is DioException) {
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
        case DioExceptionType.badResponse:
          return _mapStatusCodeToMessage(error.response?.statusCode);
        default:
          return 'Something went wrong, please check your connection.';
      }
    } else {
      return 'Something went wrong, please try again';
    }
  }

  static String _mapStatusCodeToMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
      case 401:
      case 403:
      case 404:
      case 409:
        return 'Something went wrong, please try again.';
      case 422:
        return 'No Data Found. ';
      case 500:
      case 502:
      case 503:
        return 'Internal server error, please try again later.';
      default:
        return 'Something went wrong, please try again.';
    }
  }
}

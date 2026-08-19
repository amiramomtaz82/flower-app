import '../../core/app_constants/app_strings.dart';
import '../error/error_handler.dart';

sealed class BaseResponse<T> {
  const BaseResponse();
}

class SuccessResponse<T> extends BaseResponse<T> {
  final T data;

  const SuccessResponse(this.data);
}

class ErrorResponse<T> extends BaseResponse<T> {
  final Object? error;
  final String errMessage;
  final int? statusCode;

  ErrorResponse({this.error, String? errMessage})
    : errMessage = error != null
          ? ErrorHandler.extractErrorMessage(error)
          : (errMessage ?? AppStrings.somethingWentWrong),
      statusCode = error != null ? ErrorHandler.extractStatusCode(error) : null;

  bool get isUnauthorized => statusCode == 401;
}

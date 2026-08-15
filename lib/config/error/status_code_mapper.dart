import '../../core/app_constants/app_strings.dart';

class StatusCodeMapper {
  StatusCodeMapper._();

  static const Map<int, String> _messages = {
    400: AppStrings.invalidRequest,
    401: AppStrings.sessionExpired,
    403: AppStrings.noPermission,
    404: AppStrings.dataNotFound,
    409: AppStrings.conflictOccurred,
    422: AppStrings.invalidFields,
    500: AppStrings.internalServerError,
    502: AppStrings.internalServerError,
    503: AppStrings.internalServerError,
  };

  static String toMessage(int? statusCode) =>
      _messages[statusCode] ?? AppStrings.somethingWentWrong;
}

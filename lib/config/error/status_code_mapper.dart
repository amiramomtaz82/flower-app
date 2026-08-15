import '../../core/app_constants/app_strings.dart';

class StatusCodeMapper {
  StatusCodeMapper._();

  static String toMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return AppStrings.invalidRequest;
      case 401:
        return AppStrings.sessionExpired;
      case 403:
        return AppStrings.noPermission;
      case 404:
        return AppStrings.dataNotFound;
      case 409:
        return AppStrings.conflictOccurred;
      case 422:
        return AppStrings.invalidFields;
      case 500:
      case 502:
      case 503:
        return AppStrings.internalServerError;
      default:
        return AppStrings.somethingWentWrong;
    }
  }
}

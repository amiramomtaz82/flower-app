class StatusCodeMapper {
  StatusCodeMapper._();

  static String toMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request, please check your input.';
      case 401:
        return 'Your session has expired, please log in again.';
      case 403:
        return 'You don\'t have permission to do this.';
      case 404:
        return 'The requested data was not found.';
      case 409:
        return 'Conflict occurred, the data might already exist.';
      case 422:
        return 'Some fields are invalid, please check your input.';
      case 500:
      case 502:
      case 503:
        return 'Internal server error, please try again later.';
      default:
        return 'Something went wrong, please try again.';
    }
  }
}

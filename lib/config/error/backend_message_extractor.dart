import 'package:dio/dio.dart';

class BackendMessageExtractor {
  BackendMessageExtractor._();

  static String? extract(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      // backend returns a structured error response ? extract the message from it.
      // `messageLocalized` comes back in the language the request asked for,
      // while `message` stays in the fixed technical format, so prefer it.
      final message =
          data['messageLocalized'] ??
          data['message'] ??
          data['error'] ??
          data['msg'];
      if (message is String && message.trim().isNotEmpty) return message;
      // if the error is a plain string, we can return it directly
    } else if (data is String && data.trim().isNotEmpty) {
      return data;
    }
    return null;
  }
}

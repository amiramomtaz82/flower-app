import 'package:dio/dio.dart';

import '../../../../config/secure_storage/secure_storage.dart';



class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final token = await SecureStorage.getToken();

    if (token != null && token.isNotEmpty) {
      options.headers['token'] = token;
    }

    handler.next(options);
  }
}


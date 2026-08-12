import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../config/secure_storage/secure_storage.dart';

@injectable
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

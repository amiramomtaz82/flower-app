import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../config/secure_storage/secure_storage.dart';

@injectable
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage);

  final SecureStorage _secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.getToken();

    if (token != null && token.isNotEmpty) {
      options.headers['token'] = token;
    }

    handler.next(options);
  }
}

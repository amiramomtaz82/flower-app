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
    final token = await _secureStorage.getAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers['accessToken'] = token;
    }

    handler.next(options);
  }

  // If the backend returns a 401 Unauthorized error,
  //we can delete the token from secure storage
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _secureStorage.deleteAccessToken();
    }
    handler.next(err);
  }
}

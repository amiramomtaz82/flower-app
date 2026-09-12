import 'package:dio/dio.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:injectable/injectable.dart';

import '../../../../config/secure_storage/secure_storage.dart';

@injectable
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage);

  final SecureStorage _secureStorage;

  static const String _accessTokenKey = AppStrings.accessToken;

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final token = await _secureStorage.read(key: _accessTokenKey);

    // Debug print to confirm whether storage actually holds the token
    // print('AuthInterceptor -> read token: $token');

    if (token != null && token.isNotEmpty) {
      // Must match Postman: 'Authorization': 'Bearer <token>'
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    if (err.response?.statusCode == 401) {
      await _secureStorage.delete(key: _accessTokenKey);
    }

    handler.next(err);
  }
}

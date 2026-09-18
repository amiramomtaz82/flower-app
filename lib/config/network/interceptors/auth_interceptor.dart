import 'package:dio/dio.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:injectable/injectable.dart';

import '../../../../config/secure_storage/secure_storage.dart';
import 'package:flower_app/core/app_constants/endpoints.dart';

@injectable
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage);

  final SecureStorage _secureStorage;

  static const String _accessTokenKey = AppStrings.accessToken;
  static const String _refreshTokenKey = AppStrings.refreshToken;
  
  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final token = await _secureStorage.read(key: _accessTokenKey);

    if (token != null && token.isNotEmpty) {
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
      if (!_isRefreshing) {
        _isRefreshing = true;
        try {
          final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
          if (refreshToken != null && refreshToken.isNotEmpty) {
            final refreshDio = Dio(BaseOptions(baseUrl: err.requestOptions.baseUrl));
            final response = await refreshDio.post(
              Endpoints.refreshToken,
              data: {'refreshToken': refreshToken},
            );

            if (response.statusCode == 200 || response.statusCode == 201) {
              final newAccessToken = response.data['accessToken'];
              final newRefreshToken = response.data['refreshToken'];

              if (newAccessToken != null) {
                await _secureStorage.write(key: _accessTokenKey, value: newAccessToken);
              }
              if (newRefreshToken != null) {
                await _secureStorage.write(key: _refreshTokenKey, value: newRefreshToken);
              }

              // Retry the original request
              final retryDio = Dio(BaseOptions(baseUrl: err.requestOptions.baseUrl));
              err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              final retryResponse = await retryDio.fetch(err.requestOptions);
              return handler.resolve(retryResponse);
            }
          }
        } catch (e) {
          // Token refresh failed, clean up
          await _secureStorage.delete(key: _accessTokenKey);
          await _secureStorage.delete(key: _refreshTokenKey);
        } finally {
          _isRefreshing = false;
        }
      }
      
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
    }

    handler.next(err);
  }
}

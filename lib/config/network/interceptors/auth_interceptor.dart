import 'package:dio/dio.dart';
import 'package:flower_app/core/app_constants/endpoints.dart';
import 'package:flower_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this.authLocalDataSource)
      : _retryDio = Dio(
    BaseOptions(
      baseUrl: Endpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  final AuthLocalDataSource authLocalDataSource;
  final Dio _retryDio; // Isolated Dio instance without interceptors to avoid loops

  bool _isRefreshing = false;
  final List<RetryRequest> _requestQueue = [];

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final token = await authLocalDataSource.getToken();

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
    final isUnauthorized = err.response?.statusCode == 401;
    final isRefreshCall = err.requestOptions.path.contains('/auth/refresh');

    if (!isUnauthorized || isRefreshCall) {
      return handler.next(err);
    }

    final requestOptions = err.requestOptions;

    // Queue request if a refresh is already in flight
    if (_isRefreshing) {
      _requestQueue.add(RetryRequest(requestOptions, handler));
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await authLocalDataSource.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw DioException(
          requestOptions: requestOptions,
          error: 'No refresh token available',
        );
      }

      // Execute refresh via isolated Dio instance
      final response = await _retryDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data['accessToken'] as String?;
        final newRefreshToken = response.data['refreshToken'] as String?;

        if (newAccessToken == null) {
          throw DioException(
            requestOptions: requestOptions,
            error: 'Access token missing in refresh response',
          );
        }

        await authLocalDataSource.saveToken(newAccessToken);
        if (newRefreshToken != null) {
          await authLocalDataSource.saveRefreshToken(newRefreshToken);
        }

        // Retry the initial request that failed
        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        final originalResponse = await _retryDio.fetch(requestOptions);
        handler.resolve(originalResponse);

        // Retry all queued requests with the new token
        for (final queued in _requestQueue) {
          queued.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          try {
            final res = await _retryDio.fetch(queued.requestOptions);
            queued.handler.resolve(res);
          } catch (e) {
            queued.handler.reject(
              e is DioException
                  ? e
                  : DioException(requestOptions: queued.requestOptions, error: e),
            );
          }
        }
      } else {
        throw DioException(
          requestOptions: requestOptions,
          error: 'Failed to refresh token',
        );
      }
    } catch (e) {
      await authLocalDataSource.clearAuthData();

      final rejectError = e is DioException ? e : err;
      for (final queued in _requestQueue) {
        queued.handler.reject(rejectError);
      }
      handler.reject(rejectError);
    } finally {
      _isRefreshing = false;
      _requestQueue.clear();
    }
  }
}

class RetryRequest {
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;

  RetryRequest(this.requestOptions, this.handler);
}
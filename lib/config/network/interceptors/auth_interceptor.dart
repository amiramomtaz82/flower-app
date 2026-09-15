import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flower_app/core/app_constants/endpoints.dart';
import 'package:flower_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:injectable/injectable.dart';

@lazySingleton // Must be a singleton so all requests share the same queue
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
  final Dio _retryDio;

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

    // 1. If currently refreshing, enqueue and wait
    if (_isRefreshing) {
      _requestQueue.add(RetryRequest(err.requestOptions, handler));
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await authLocalDataSource.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw DioException(
          requestOptions: err.requestOptions,
          error: 'No refresh token available',
        );
      }

      // 2. Call refresh endpoint
      final response = await _retryDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data?['accessToken'] as String?;
      final newRefreshToken = response.data?['refreshToken'] as String?;

      if (response.statusCode != 200 || newAccessToken == null) {
        throw DioException(
          requestOptions: err.requestOptions,
          error: 'Failed to refresh token',
        );
      }

      await authLocalDataSource.saveToken(newAccessToken);
      if (newRefreshToken != null) {
        await authLocalDataSource.saveRefreshToken(newRefreshToken);
      }

      // 3. Retry the initial request
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      _retryRequest(err.requestOptions, handler);

      // 4. Drain existing queue snapshot safely
      final queueSnapshot = List<RetryRequest>.from(_requestQueue);
      _requestQueue.clear();

      for (final queued in queueSnapshot) {
        queued.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        _retryRequest(queued.requestOptions, queued.handler);
      }
    } catch (e) {
      await authLocalDataSource.clearAuthData();

      final rejectError = e is DioException ? e : err;
      final queueSnapshot = List<RetryRequest>.from(_requestQueue);
      _requestQueue.clear();

      for (final queued in queueSnapshot) {
        queued.handler.reject(rejectError);
      }
      handler.reject(rejectError);
    } finally {
      _isRefreshing = false;
    }
  }

  void _retryRequest(RequestOptions options, dynamic handler) {
    _retryDio.fetch(options).then(
          (response) => handler.resolve(response),
      onError: (error) {
        final dioError = error is DioException
            ? error
            : DioException(requestOptions: options, error: error);
        handler.reject(dioError);
      },
    );
  }
}

class RetryRequest {
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;

  RetryRequest(this.requestOptions, this.handler);
}
import 'package:dio/dio.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_constants/endpoints.dart';
import 'package:flower_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this.authLocalDataSource);

  final AuthLocalDataSource authLocalDataSource;
  
  final Dio refreshDio = Dio(
    BaseOptions(
      baseUrl: Endpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  bool isRefreshing = false;
  final requestQueue = <RetryRequest>[];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await authLocalDataSource.getToken();

    if (token != null && token.isNotEmpty) {
      options.headers[AppStrings.accessToken] = token;
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final requestOptions = err.requestOptions;
      
      if (isRefreshing) {
        requestQueue.add(RetryRequest(requestOptions, handler));
        return;
      }

      isRefreshing = true;

      try {
        final refreshToken = await authLocalDataSource.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          throw Exception("No refresh token available");
        }

        final response = await refreshDio.post(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
        );

        if (response.statusCode == 200) {
          final newAccessToken = response.data['accessToken'];
          final newRefreshToken = response.data['refreshToken'];

          await authLocalDataSource.saveToken(newAccessToken);
          if (newRefreshToken != null) {
            await authLocalDataSource.saveRefreshToken(newRefreshToken);
          }

          requestOptions.headers[AppStrings.accessToken] = newAccessToken;
          
          final retryDio = Dio(
            BaseOptions(
              baseUrl: Endpoints.baseUrl,
            )
          );
          
          final retryResponse = await retryDio.fetch(requestOptions);
          handler.resolve(retryResponse);

          for (final req in requestQueue) {
            req.requestOptions.headers[AppStrings.accessToken] = newAccessToken;
            try {
              final res = await retryDio.fetch(req.requestOptions);
              req.handler.resolve(res);
            } catch (e) {
              req.handler.reject(e is DioException ? e : DioException(requestOptions: req.requestOptions, error: e));
            }
          }
        } else {
          throw Exception("Failed to refresh token");
        }
      } catch (e) {
        await authLocalDataSource.clearAuthData();
        for (final req in requestQueue) {
          req.handler.reject(err);
        }
        handler.next(err);
      } finally {
        isRefreshing = false;
        requestQueue.clear();
      }
    } else {
      handler.next(err);
    }
  }
}

class RetryRequest {
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;

  RetryRequest(this.requestOptions, this.handler);
}

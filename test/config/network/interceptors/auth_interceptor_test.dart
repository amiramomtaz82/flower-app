import 'package:dio/dio.dart';
import 'package:flower_app/config/network/interceptors/auth_interceptor.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/config/secure_storage/secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_interceptor_test.mocks.dart';

@GenerateMocks([
  SecureStorage,
  RequestInterceptorHandler,
  ErrorInterceptorHandler,
])
void main() {
  late AuthInterceptor authInterceptor;
  late MockSecureStorage mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockSecureStorage();
    authInterceptor = AuthInterceptor(mockSecureStorage);
  });

  group('onRequest', () {
    test('adds token to headers if available', () async {
      when(mockSecureStorage.read(key: AppStrings.accessToken))
          .thenAnswer((_) async => 'valid_token');
      
      final options = RequestOptions(path: '/test');
      final handler = MockRequestInterceptorHandler();

      await authInterceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer valid_token');
      verify(handler.next(options)).called(1);
    });

    test('does not add token if null or empty', () async {
      when(mockSecureStorage.read(key: AppStrings.accessToken))
          .thenAnswer((_) async => '');
      
      final options = RequestOptions(path: '/test');
      final handler = MockRequestInterceptorHandler();

      await authInterceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
      verify(handler.next(options)).called(1);
    });
  });

  group('onError', () {
    test('deletes token on 401', () async {
      final err = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );
      final handler = MockErrorInterceptorHandler();

      when(mockSecureStorage.delete(key: AppStrings.accessToken))
          .thenAnswer((_) async {});

      await authInterceptor.onError(err, handler);

      verify(mockSecureStorage.delete(key: AppStrings.accessToken)).called(1);
      verify(handler.next(err)).called(1);
    });
  });
}

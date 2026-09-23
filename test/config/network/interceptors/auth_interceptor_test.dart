import 'package:dio/dio.dart';
import 'package:flower_app/config/network/interceptors/auth_interceptor.dart';
import 'package:flower_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

class FakeRequestOptions extends Fake implements RequestOptions {}

class FakeDioException extends Fake implements DioException {}

void main() {
  late AuthInterceptor authInterceptor;
  late MockAuthLocalDataSource mockAuthLocalDataSource;

  setUpAll(() {
    dotenv.loadFromString(envString: 'BASE_URL=https://api.example.com');
    registerFallbackValue(FakeRequestOptions());
    registerFallbackValue(FakeDioException());
  });

  setUp(() {
    mockAuthLocalDataSource = MockAuthLocalDataSource();
    authInterceptor = AuthInterceptor(mockAuthLocalDataSource);
  });

  group('onRequest', () {
    test('adds token to headers if available', () async {
      when(() => mockAuthLocalDataSource.getToken())
          .thenAnswer((_) async => 'valid_token');

      final options = RequestOptions(path: '/test');
      final handler = MockRequestInterceptorHandler();

      await authInterceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer valid_token');
      verify(() => handler.next(options)).called(1);
    });

    test('does not add token if null or empty', () async {
      when(() => mockAuthLocalDataSource.getToken())
          .thenAnswer((_) async => '');

      final options = RequestOptions(path: '/test');
      final handler = MockRequestInterceptorHandler();

      await authInterceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
      verify(() => handler.next(options)).called(1);
    });
  });

  group('onError', () {
    test('passes error through handler.next if not 401', () async {
      final err = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
        ),
      );
      final handler = MockErrorInterceptorHandler();

      await authInterceptor.onError(err, handler);

      verify(() => handler.next(err)).called(1);
      verifyNever(() => mockAuthLocalDataSource.clearAuthData());
    });

    test('passes error through handler.next if 401 on refresh path', () async {
      final err = DioException(
        requestOptions: RequestOptions(path: '/auth/refresh'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          statusCode: 401,
        ),
      );
      final handler = MockErrorInterceptorHandler();

      await authInterceptor.onError(err, handler);

      verify(() => handler.next(err)).called(1);
      verifyNever(() => mockAuthLocalDataSource.clearAuthData());
    });

    test('clears auth data and rejects when no refresh token on 401', () async {
      final err = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );
      final handler = MockErrorInterceptorHandler();

      when(() => mockAuthLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => null);
      when(() => mockAuthLocalDataSource.clearAuthData())
          .thenAnswer((_) async {});

      await authInterceptor.onError(err, handler);

      verify(() => mockAuthLocalDataSource.clearAuthData()).called(1);
      verify(() => handler.reject(any())).called(1);
    });
  });
}

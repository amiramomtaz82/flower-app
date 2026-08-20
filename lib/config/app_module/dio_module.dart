import 'package:dio/dio.dart';
import 'package:flower_app/config/network/interceptors/auth_interceptor.dart';
import 'package:flower_app/config/network/interceptors/locale_interceptor.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../core/app_constants/endpoints.dart';

@module
abstract class DioModule {
  @singleton
  Dio dio(AuthInterceptor authInterceptor, LocaleInterceptor localeInterceptor) {
    final dioInstance = Dio(
      BaseOptions(
        baseUrl: Endpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dioInstance.interceptors.add(authInterceptor);
    dioInstance.interceptors.add(localeInterceptor);
    dioInstance.interceptors.add(
      PrettyDioLogger(
        requestBody: true,
        requestHeader: true,
        responseBody: true,
        responseHeader: false,
      ),
    );
    return dioInstance;
  }
}

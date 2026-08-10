import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';



import '../../core/app_constants/endpoints.dart';
import '../../features/auth/api/interceptor/auth_interceptor.dart';

@module
abstract class DioModule {
  @singleton
  Dio get dio {
    final dioInstance = Dio(
      BaseOptions(
        baseUrl: Endpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dioInstance.interceptors.add(AuthInterceptor());
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
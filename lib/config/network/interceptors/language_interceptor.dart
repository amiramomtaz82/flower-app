import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

@injectable
class LanguageInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    options.headers['Accept-Language'] = locale.languageCode;
    handler.next(options);
  }
}

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../config/locale/locale_service.dart';

/// Sends the language the app is currently showing so the backend can localize
/// the messages it returns. Every endpoint requires the header.
@injectable
class LocaleInterceptor extends Interceptor {
  LocaleInterceptor(this._localeService);

  final LocaleService _localeService;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] = _localeService.languageCode;
    handler.next(options);
  }
}

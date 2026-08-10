import 'package:dio/dio.dart';

import '../../../../config/shared_prefrences/shared_prefs.dart';

class AuthInterceptor extends Interceptor {

  @override
  void onRequest(RequestOptions options,
      RequestInterceptorHandler handler) async {

    final token= await SharedPrefsUtils().getToken();
    options.headers.addAll({

      "token": token
    });
    super.onRequest(options, handler);
  }
}
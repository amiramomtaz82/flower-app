import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Exposes the app's current language to consumers that live outside the
/// widget tree, such as the Dio `LocaleInterceptor`.
///
/// EasyLocalization stays the owner of the locale and its persistence; this
/// mirrors it so non-widget code can read it synchronously, and exposes a
/// listenable so anything that needs to react to a language change can.
@lazySingleton
class LocaleService {
  final ValueNotifier<String> _languageCode = ValueNotifier<String>('en');

  ValueListenable<String> get languageCodeListenable => _languageCode;

  String get languageCode => _languageCode.value;

  void setLanguageCode(String code) {
    if (_languageCode.value == code) return;
    _languageCode.value = code;
  }
}

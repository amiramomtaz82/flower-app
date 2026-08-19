import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

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

import 'package:injectable/injectable.dart';
import 'package:nominatim_flutter/nominatim_flutter.dart';

@module
abstract class ThirdPartyModule {
  @lazySingleton
  NominatimFlutter get nominatim {
    final instance = NominatimFlutter.instance;
    instance.configureNominatim(
      userAgent: 'FlowerApp/1.0',
    );
    return instance;
  }
}